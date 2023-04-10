//
//  BluetoothStore.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT
import DarwinGATT
import BluetoothAccessory

// MARK: - Subscript

public extension AccessoryManager {
        
    /// Bluetooth ``Peripheral`` for the Accessory with the specified ID.
    subscript (peripheral id: UUID) -> Peripheral? {
        accessoryPeripherals[id]?.peripheral
    }
    
    /// Get the discovered accessory with advertised identifiers for the specified peripheral.
    subscript (accessory peripheral: Peripheral) -> AccessoryPeripheral? {
        accessoryPeripherals.values.first(where: { $0.peripheral == peripheral })
    }
    
    /// Get the discovered beacon for the specified peripheral.
    subscript (beacon peripheral: Peripheral) -> AccessoryBeacon? {
        scanResults[peripheral]?.beacon.flatMap { AccessoryBeacon(beacon: $0) }
    }
    
    /// Get the discovered manufacturer data for the specified peripheral.
    subscript (manufacturerData peripheral: Peripheral) -> AccessoryManufacturerData? {
        scanResults[peripheral]?.manufacturerData.flatMap { AccessoryManufacturerData(manufacturerData: $0) }
    }
}

// MARK: - Methods

public extension AccessoryManager {
    
    /// Wait for CoreBluetooth to be ready.
    func wait(
        for state: DarwinBluetoothState,
        warning: Int = 3,
        timeout: Int = 10
    ) async throws {
        
        var powerOnWait = 0
        var currentState = await central.state
        while currentState != state {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            powerOnWait += 1
            // inform user after 3 seconds
            if powerOnWait == warning {
                log("Waiting for CoreBluetooth to be ready, please turn on Bluetooth")
            }
            guard powerOnWait < timeout
                else { throw DarwinCentralError.invalidState(currentState) }
            currentState = await central.state // update value for next loop
        }
    }
    
    func peripheral(for id: UUID) async throws -> AccessoryPeripheral {
        // return cached value
        if let peripheral = accessoryPeripherals[id] {
            return peripheral
        }
        // TODO: Scan
        try await self.scan(duration: 1)
        // return cached value
        guard let peripheral = accessoryPeripherals[id] else {
            throw BluetoothAccessoryError.notInRange(id)
        }
        return peripheral
    }
    
    func scan(
        duration: TimeInterval? = nil,
        services: [ServiceType] = ServiceType.allCases
    ) async throws {
        let bluetoothState = await central.state
        guard bluetoothState == .poweredOn else {
            throw DarwinCentralError.invalidState(bluetoothState)
        }
        let filterDuplicates = true //preferences.filterDuplicates
        self.accessoryPeripherals.removeAll(keepingCapacity: true)
        self.scanResults.removeAll(keepingCapacity: true)
        stopScanning()
        isScanning = true
        let scanStream = central.scan(
            with: Set(services.lazy.map { BluetoothUUID(service: $0) }),
            filterDuplicates: filterDuplicates
        )
        self.scanStream = scanStream
        let task = Task { [unowned self] in
            do {
                for try await scanData in scanStream {
                    guard await found(scanData) else { continue }
                }
                self.isScanning = false
            }
            catch {
                self.isScanning = false
                throw error
            }
        }
        // wait for duration or continue in background
        if let duration = duration {
            assert(duration > 0.001)
            try await Task.sleep(timeInterval: duration)
            scanStream.stop()
            try await task.value // throw errors
        } else {
            // error not thrown
            Task { [unowned self] in
                do { try await task.value }
                catch is CancellationError { }
                catch {
                    self.log("Error scanning: \(error)")
                }
            }
        }
    }
    
    func stopScanning() {
        scanStream?.stop()
        scanStream = nil
        isScanning = false
    }
    
    func connection<T>(
        for peripheral: Peripheral,
        _ connection: (GATTConnection<Central>) async throws -> (T)
    ) async throws -> T {
        let bluetoothState = await central.state
        guard bluetoothState == .poweredOn else {
            throw DarwinCentralError.invalidState(bluetoothState)
        }
        await updatePeripherals()
        while let isConnected = peripherals[peripheral], isConnected {
            // wait for previous connection to finish
            try await Task.sleep(timeInterval: 1.0)
            await updatePeripherals()
        }
        // force stop scanning
        if isScanning {
            stopScanning()
        }
        // open connection
        return try await central.connection(
            for: peripheral,
            connection
        )
    }
    
    /// Discovery all services characteristics. Metadata for each characteristic must be provided.
    @discardableResult
    func discoverCharacteristics(
        connection: GATTConnection<Central>,
        custom: Bool = true
    ) async throws -> [(service: BluetoothUUID, metadata: CharacteristicMetadata)] {
        // read identifier
        let id = try await identifier(connection: connection)
        let _ = try await readInformation(connection: connection)
        // TODO: Fetch custom metadata
        let customMetadata = [BluetoothUUID: CharacteristicMetadata]()
        // iterate each service
        var characteristics = [(service: BluetoothUUID, metadata: CharacteristicMetadata)]()
        for service in connection.cache.services {
            let serviceUUID = service.service.uuid
            for characteristicCache in service.characteristics {
                let uuid = characteristicCache.characteristic.uuid
                // attempt to fetch metadata for defined characteristic
                guard let metadata = BluetoothUUID.accessoryCharacteristicType[uuid].flatMap({ CharacteristicMetadata(type: $0) }) ?? customMetadata[uuid] else {
                    continue
                }
                characteristics.append(
                    (serviceUUID, metadata)
                )
            }
        }
        try await updateCoreDataCharacteristics(characteristics, for: id)
        return characteristics
    }
    
    @discardableResult
    func read(
        characteristic characteristicUUID: BluetoothUUID,
        service: BluetoothUUID,
        connection: GATTConnection<Central>
    ) async throws -> CharacteristicCache.Value {
        let id = try await identifier(connection: connection)
        let metadata = try self.managedObjectContext.metadata(for: characteristicUUID, service: service, accessory: id)
        assert(metadata.type == characteristicUUID)
        let characteristic = try connection.cache.characteristic(characteristicUUID, service: service)
        assert(characteristic.uuid == characteristicUUID)
        // must be readable
        guard metadata.properties.contains(.read) else {
            assertionFailure()
            throw CocoaError(.featureUnsupported)
        }
        // must be single value
        guard metadata.properties.contains(.list) == false else {
            assertionFailure()
            throw CocoaError(.featureUnsupported)
        }
        let newValue: CharacteristicCache.Value
        if metadata.properties.contains(.encrypted) {
            guard let key = self.key(for: id) else {
                throw BluetoothAccessoryError.authenticationRequired(characteristic.uuid)
            }
            let cryptoHash = try connection.cache.characteristic(.cryptoHash, service: .authentication)
            let authentication = try connection.cache.characteristic(.authenticate, service: .authentication)
            // read list
            if metadata.properties.contains(.list) {
                let stream = try await central.readList(
                    characteristic: characteristic,
                    service: service,
                    cryptoHash: cryptoHash,
                    authentication: authentication,
                    key: key,
                    format: metadata.format
                )
                var values = [CharacteristicValue]()
                for try await value in stream {
                    try await addCoreDataCharacteristicListValue(value, for: characteristicUUID, service: service, accessory: id)
                    values.append(value)
                }
                newValue = .list(values)
            } else {
                // TODO: validate key permission
                let value = try await central.readEncryped(
                    characteristic: characteristic,
                    service: service,
                    cryptoHash: cryptoHash,
                    authentication: authentication,
                    key: key,
                    format: metadata.format
                )
                newValue = .single(value)
                try await updateCoreDataCharacteristicValue(newValue, for: characteristicUUID, service: service, accessory: id)
            }
        } else {
            let value = try await central.read(
                characteristic: characteristic,
                format: metadata.format
            )
            newValue = .single(value)
            try await updateCoreDataCharacteristicValue(newValue, for: characteristicUUID, service: service, accessory: id)
        }
        return newValue
    }
    
    func write(
        _ newValue: CharacteristicValue,
        characteristic characteristicUUID: BluetoothUUID,
        service: BluetoothUUID,
        connection: GATTConnection<Central>
    ) async throws {
        let id = try await identifier(connection: connection)
        let metadata = try self.managedObjectContext.metadata(for: characteristicUUID, service: service, accessory: id)
        assert(metadata.type == characteristicUUID)
        let characteristic = try connection.cache.characteristic(characteristicUUID, service: service)
        assert(characteristic.uuid == characteristicUUID)
        // must be readable
        guard metadata.properties.contains(.read) else {
            assertionFailure()
            throw CocoaError(.featureUnsupported)
        }
        // must be single value
        guard metadata.properties.contains(.list) == false else {
            assertionFailure()
            throw CocoaError(.featureUnsupported)
        }
        // write encrypted
        if metadata.properties.contains(.encrypted) {
            guard let key = self.key(for: id) else {
                throw BluetoothAccessoryError.authenticationRequired(characteristic.uuid)
            }
            // TODO: validate key permission
            try await central.writeEncrypted(
                newValue,
                for: characteristic,
                cryptoHash: connection.cache.characteristic(.cryptoHash, service: .authentication),
                key: key
            )
        } else {
            try await central.write(newValue, for: characteristic)
        }
        // update cache
        try await updateCoreDataCharacteristicValue(.single(newValue), for: characteristicUUID, service: service, accessory: id)
    }
    
    func setup(
        _ peripheral: AccessoryPeripheral,
        using sharedSecret: KeyData,
        name: String
    ) async throws {
        let keyData = KeyData()
        let request = SetupRequest(
            id: UUID(),
            secret: keyData,
            name: name
        )
        let information = try await self.connection(for: peripheral.peripheral) { connection in
            try await connection.setup(request, using: sharedSecret)
            // read information
            return try await readInformation(connection: connection)
        }
        // cache key
        let key = Key(setup: request)
        let accessory = PairedAccessory(
            information: information,
            key: key
        )
        self[key: key.id] = keyData
        self[cache: information.id] = accessory
    }
    
    
}

// MARK: - Internal Methods

internal extension AccessoryManager {
    
    func loadBluetooth() -> Central {
        let central = NativeCentral(options: configuration.central)
        central.log = { [unowned self] in self.log("📲 Central: " + $0) }
        observeBluetoothState(central)
        return central
    }
    
    /// Load cached identifier or read from device.
    func identifier(
        connection: GATTConnection<Central>
    ) async throws -> UUID {
        // load cached
        if let uuid = self.accessoryPeripherals.first(where: { $0.value.peripheral == connection.peripheral })?.key {
            return uuid
        }
        // read identifier
        let id = try await connection.readIdentifier()
        // cache new found device
        if let scanResponse = self.scanResponses[connection.peripheral] {
            self.accessoryPeripherals[id] = .init(
                peripheral: connection.peripheral,
                id: id,
                name: scanResponse.name,
                service: scanResponse.service
            )
        }
        return id
    }
    
    func readInformation(
        connection: GATTConnection<Central>
    ) async throws -> AccessoryInformation {
        guard let scanResponse = self.scanResponses[connection.peripheral] else {
            assertionFailure()
            throw BluetoothAccessoryError.incompatiblePeripheral
        }
        let id = try await self.identifier(connection: connection)
        let name = try await connection.readName()
        let accessoryType = try await connection.readAccessoryType()
        let manufacturer = try await connection.readManufacturer()
        let softwareVersion = try await connection.readSoftwareVersion()
        let model = try await connection.readModel()
        let serialNumber = try await connection.readSerialNumber()
        let information = AccessoryInformation(
            id: id,
            name: name,
            accessory: accessoryType,
            service: scanResponse.service,
            manufacturer: manufacturer,
            serialNumber: serialNumber,
            model: model,
            softwareVersion: softwareVersion
        )
        // update Core Data
        try await cacheCoreDataAccessory(information)
        return information
    }
}

private extension AccessoryManager {
    
    func observeBluetoothState(_ central: NativeCentral) {
        self.centralObserver = central.objectWillChange.sink(receiveValue: {
            Task { [weak self] in
                await self?.updatePeripherals()
                await self?.updateBluetoothState()
            }
        })
    }
    
    func updateBluetoothState() async {
        let newState = await self.central.state
        let oldValue = self.state
        if newState != oldValue {
            self.state = newState
        }
    }
    
    func updatePeripherals() async {
        let newValue = await self.central.peripherals
        let oldValue = self.peripherals
        if newValue != oldValue {
            self.peripherals = newValue
        }
    }
    
    func found(_ scanData: ScanData) async -> Bool {
        
        // parse scan response
        if let name = scanData.advertisementData.localName,
           let services = scanData.advertisementData.serviceUUIDs?.compactMap({ BluetoothUUID.accessoryServiceTypes[$0] }),
           let service = services.first {
            // cache
            let scanResponse = AccessoryScanResponse(
                name: name,
                service: service
            )
            scanResponses[scanData.peripheral] = scanResponse
        }
        
        // aggregate scan data
        assert(Thread.isMainThread)
        let oldCacheValue = scanResults[scanData.peripheral]
        // cache discovered peripheral in background
        let cache = await Task.detached { [weak central] in
            assert(Thread.isMainThread == false)
            var cache = oldCacheValue ?? ScanDataCache(scanData: scanData)
            cache += scanData
            #if canImport(CoreBluetooth)
            cache.name = try? await central?.name(for: scanData.peripheral)
            for serviceUUID in scanData.advertisementData.overflowServiceUUIDs ?? [] {
                cache.overflowServiceUUIDs.insert(serviceUUID)
            }
            #endif
            return cache
        }.value
        scanResults[scanData.peripheral] = cache
        assert(Thread.isMainThread)
        
        // optimization
        guard let name = cache.advertisedName, cache.serviceUUIDs.isEmpty else {
            return false
        }
        
        // parse accessory aggregated advertisement data
        let services = cache.serviceUUIDs.compactMap { BluetoothUUID.accessoryServiceTypes[$0] }
        guard let service = services.first else {
            return false
        }
        
        // cache identified accessory
        let manufacturerData = cache.manufacturerData.flatMap { AccessoryManufacturerData(manufacturerData: $0) }
        let accessoryBeacon = cache.beacon.flatMap { AccessoryBeacon(beacon: $0) }
        guard let id = manufacturerData?.id ?? accessoryBeacon?.uuid else {
            return false
        }
        
        let accessory = AccessoryPeripheral(
            peripheral: scanData.peripheral,
            id: id,
            name: name,
            service: service
        )
        assert(Thread.isMainThread)
        accessoryPeripherals[id] = accessory
        return true
    }
}

// MARK: - Typealias

public extension AccessoryManager {
    
    typealias Central = NativeCentral
    
    typealias Peripheral = Central.Peripheral
    
    typealias ScanData = GATT.ScanData<Central.Peripheral, Central.Advertisement>
    
    typealias Service = GATT.Service<Central.Peripheral, Central.AttributeID>
    
    typealias Characteristic = GATT.Characteristic<Central.Peripheral, Central.AttributeID>
    
    typealias Descriptor = GATT.Descriptor<Central.Peripheral, Central.AttributeID>
    
    typealias ScanDataCache = BluetoothAccessoryKit.ScanDataCache<Central.Peripheral, Central.Advertisement>
    
    typealias AccessoryPeripheral = BluetoothAccessoryKit.AccessoryPeripheral<Central.Peripheral>
}
