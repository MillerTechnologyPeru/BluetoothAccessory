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

public extension AccessoryStore {
    
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

public extension AccessoryStore {
    
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
}

// MARK: - Internal Methods

internal extension AccessoryStore {
    
    func loadBluetooth() {
        central.log = { [unowned self] in self.log("📲 Central: " + $0) }
        observeBluetoothState()
    }
}

private extension AccessoryStore {
    
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

public extension AccessoryStore {
    
    typealias Central = NativeCentral
    
    typealias Peripheral = Central.Peripheral
    
    typealias ScanData = GATT.ScanData<Central.Peripheral, Central.Advertisement>
    
    typealias Service = GATT.Service<Central.Peripheral, Central.AttributeID>
    
    typealias Characteristic = GATT.Characteristic<Central.Peripheral, Central.AttributeID>
    
    typealias Descriptor = GATT.Descriptor<Central.Peripheral, Central.AttributeID>
    
    typealias ScanDataCache = BluetoothAccessoryKit.ScanDataCache<Central.Peripheral, Central.Advertisement>
    
    typealias AccessoryPeripheral = BluetoothAccessoryKit.AccessoryPeripheral<Central.Peripheral>
}
