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

public extension AccessoryManager {
    
    // MARK: - Subscript
    
    /// Bluetooth ``Peripheral`` for the Accessory with the specified ID.
    subscript (peripheral id: UUID) -> Peripheral? {
        accessoryPeripherals[id]?.peripheral
    }
    
    /// Service Type for the specified ``BluetoothUUID``
    internal subscript (service uuid: BluetoothUUID) -> ServiceType? {
        serviceTypes[uuid]
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
        
    func scan(
        duration: TimeInterval? = nil,
        services: [ServiceType] = []
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
        // cache new value
        if let scanResponse = self.scanResponses[connection.peripheral] {
            self.accessoryPeripherals[id] = .init(peripheral: connection.peripheral, id: id, name: scanResponse.name, service: scanResponse.service)
        }
        return id
    }
    
    /// Discovery all services characteristics. Metadata for each characteristic must be provided via
    func discoverCharacteristics(
        connection: GATTConnection<Central>
    ) async throws {
        let characteristicTypes = self.characteristicTypes
        // TODO: Fetch custom metadata
        let customMetadata = [BluetoothUUID: CharacteristicMetadata]()
        var discoveredCharacteristics = [Characteristic: (service: BluetoothUUID, metadata: CharacteristicMetadata)]()
        // iterate each service
        for service in connection.cache.services {
            let serviceUUID = service.service.uuid
            for characteristicCache in service.characteristics {
                let uuid = characteristicCache.characteristic.uuid
                /// attempt to fetch metadata for defined characteristic
                guard let metadata = characteristicTypes[uuid].flatMap({ CharacteristicMetadata(characteristic: $0) }) ?? customMetadata[uuid] else {
                    continue
                }
                // cache
                discoveredCharacteristics[characteristicCache.characteristic] = (serviceUUID, metadata)
            }
        }
        // set new discovered characteristics for the specified peripheral with previous values
        var newValue = [Characteristic: CharacteristicCache]()
        newValue.reserveCapacity(discoveredCharacteristics.count)
        for (characteristic, (service, metadata)) in discoveredCharacteristics {
            assert(characteristic.peripheral == connection.peripheral)
            newValue[characteristic] = CharacteristicCache(
                service: service,
                metadata: metadata,
                value: self.characteristics[characteristic.peripheral, default: [:]][characteristic]?.value
            )
        }
        // set new value
        self.characteristics[connection.peripheral] = newValue
    }
    
    func read(
        characteristic: Characteristic,
        connection: GATTConnection<Central>
    ) async throws -> CharacteristicValue {
        assert(characteristic.peripheral == connection.peripheral)
        guard let cache = self.characteristics[characteristic.peripheral]?[characteristic] else {
            throw BluetoothAccessoryError.metadataRequired(characteristic.uuid)
        }
        assert(cache.metadata.type == characteristic.uuid)
        // must be readable
        guard cache.metadata.properties.contains(.read) else {
            assertionFailure()
            throw CocoaError(.featureUnsupported)
        }
        // must be single value
        guard cache.metadata.properties.contains(.list) == false else {
            assertionFailure()
            throw CocoaError(.featureUnsupported)
        }
        let newValue: CharacteristicValue
        if cache.metadata.properties.contains(.encrypted) {
            let id = try await identifier(connection: connection)
            guard let key = self.keys[id] else {
                throw BluetoothAccessoryError.authenticationRequired(characteristic.uuid)
            }
            // TODO: validate key permission
            let keyData = try secret(for: key.id)
            let credential = Credential(
                id: key.id,
                secret: keyData
            )
            newValue = try await central.readEncryped(
                characteristic: characteristic,
                service: cache.service,
                cryptoHash: connection.cache.characteristic(.cryptoHash, service: .authentication),
                authentication: connection.cache.characteristic(.authenticate, service: .authentication),
                key: credential,
                format: cache.metadata.format
            )
        } else {
            newValue = try await central.read(
                characteristic: characteristic,
                format: cache.metadata.format
            )
        }
        // update cache
        self.characteristics[characteristic.peripheral, default: [:]][characteristic, default: cache].value = .single(newValue)
        return newValue
    }
}

// MARK: - Internal Methods

internal extension AccessoryManager {
    
    func loadBluetooth() -> Central {
        let central = NativeCentral()
        central.log = { [unowned self] in self.log("📲 Central: " + $0) }
        Task {
            observeBluetoothState()
        }
        return central
    }
}

private extension AccessoryManager {
    
    func observeBluetoothState() {
        // observe state
        Task { [weak self] in
            while let self = self {
                let newState = await self.central.state
                let oldValue = self.state
                if newState != oldValue {
                    self.state = newState
                }
                try await Task.sleep(timeInterval: 0.5)
            }
        }
    }
    
    func found(_ scanData: ScanData) async -> Bool {
        
        // parse scan response
        if let name = scanData.advertisementData.localName,
           let services = scanData.advertisementData.serviceUUIDs?.compactMap({ self[service: $0] }),
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
        let services = cache.serviceUUIDs.compactMap { self[service: $0] }
        guard let service = services.first else {
            return false
        }
        
        // cache identified accessory
        let manufacturerData = cache.manufacturerData.flatMap { AccessoryManufacturerData(manufacturerData: $0) }
        let accessoryBeacon = cache.beacon.flatMap { AccessoryBeacon(beacon: $0) }
        guard let id = manufacturerData?.id ?? accessoryBeacon?.uuid
            else { return false }
        
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
