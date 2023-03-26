//
//  Store.swift
//
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
#if canImport(BluetoothGATT)
import BluetoothGATT
#endif
#if canImport(BluetoothGAP)
import BluetoothGAP
#endif
import GATT
import DarwinGATT
import BluetoothAccessory

@MainActor
public final class AccessoryStore: ObservableObject {
    
    // MARK: - Properties
    
    @Published
    public private(set) var state: DarwinBluetoothState = .unknown
    
    @Published
    public private(set) var isScanning = false
    
    /// Discovered accessories.
    @Published
    public private(set) var peripherals = [UUID: AccessoryPeripheral<NativeCentral.Peripheral>]()
    
    //#if canImport(BluetoothGAP)
    /// Accessory Beacons discovered via CoreBluetooth
    @Published
    public private(set) var beaconPeripherals = [NativeCentral.Peripheral: AccessoryBeacon]()
    //#endif
    
    /// Scanned accessory manufacturer data.
    @Published
    public private(set) var manufacturerData = [NativeCentral.Peripheral: AccessoryManufacturerData]()
    
    @Published
    public private(set) var scanResponses = [NativeCentral.Peripheral: AccessoryScanResponse]()
    
    /// Keys of paired devices.
    @Published
    public private(set) var keys = [UUID: Key]()
    
    lazy var central = NativeCentral()
    
    private var scanStream: AsyncCentralScan<NativeCentral>?
    
    // MARK: - Initialization
    
    public static let shared = AccessoryStore()
    
    private init() {
        central.log = { [unowned self] in self.log("📲 Central: " + $0) }
        observeBluetoothState()
    }
    
    // MARK: - Methods
    
    private func observeBluetoothState() {
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
    
    public func scan(duration: TimeInterval? = nil) async throws {
        let bluetoothState = await central.state
        guard bluetoothState == .poweredOn else {
            throw DarwinCentralError.invalidState(bluetoothState)
        }
        let filterDuplicates = true //preferences.filterDuplicates
        self.peripherals.removeAll(keepingCapacity: true)
        stopScanning()
        isScanning = true
        let scanStream = central.scan(
            with: [],
            filterDuplicates: filterDuplicates
        )
        self.scanStream = scanStream
        let task = Task { [unowned self] in
            defer { Task { await MainActor.run { self.isScanning = false } } }
            for try await scanData in scanStream {
                guard found(scanData) else { continue }
            }
        }
        if let duration = duration {
            precondition(duration > 0.001)
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
    
    public func stopScanning() {
        scanStream?.stop()
        scanStream = nil
        isScanning = false
    }
    
    private func found(_ scanData: ScanData<NativeCentral.Peripheral, NativeCentral.Advertisement>) -> Bool {
        
        // parse manufacturer data
        if let manufacturerData = scanData.advertisementData.manufacturerData,
           let accessoryManufacturerData = AccessoryManufacturerData(manufacturerData: manufacturerData) {
            let oldValue = self.manufacturerData[scanData.peripheral]
            if oldValue != accessoryManufacturerData {
                self.manufacturerData[scanData.peripheral] = accessoryManufacturerData
            }
        }
        
        // parse scan response
        if let name = scanData.advertisementData.localName,
           let service = scanData.advertisementData.serviceUUIDs?.compactMap({ ServiceType(uuid: $0) }).first {
            let oldValue = self.scanResponses[scanData.peripheral]
            let newValue = AccessoryScanResponse(
                name: name,
                service: service
            )
            if oldValue != newValue {
                self.scanResponses[scanData.peripheral] = newValue
            }
        }
        
        
        // parse iBeacon
        #if canImport(BluetoothGAP)
        // has been previously scanned
        let isAccessory = self.manufacturerData[scanData.peripheral] != nil
            || self.scanResponses[scanData.peripheral] != nil
            || self.beaconPeripherals[scanData.peripheral] != nil
        
        if isAccessory,
           let manufacturerData = scanData.advertisementData.manufacturerData,
           let beacon = AppleBeacon(manufacturerData: manufacturerData),
           let accessoryBeacon = AccessoryBeacon(beacon: beacon) {
            let oldValue = self.beaconPeripherals[scanData.peripheral]
            if oldValue != accessoryBeacon {
                self.beaconPeripherals[scanData.peripheral] = accessoryBeacon
            }
        }
        #endif
        
        // accessory requires advertisement and scan response
        guard let scanResponse = self.scanResponses[scanData.peripheral],
              let id = self.manufacturerData[scanData.peripheral]?.id ?? self.beaconPeripherals[scanData.peripheral]?.uuid else { return false }
        
        let peripheral = AccessoryPeripheral(
            peripheral: scanData.peripheral,
            id: id,
            name: scanResponse.name,
            service: scanResponse.service
        )
        
        let oldValue = self.peripherals[id]
        if oldValue != peripheral {
            self.peripherals[id] = peripheral
        }
        return true
    }
    
    public func log(_ message: String) {
        // TODO: Logs
        print(message)
    }
}

// MARK: - Supporting Types

public struct AccessoryPeripheral <Peripheral: GATT.Peer>: Equatable, Hashable, Identifiable {
    
    public let peripheral: Peripheral
    
    /// UUID from iBeacon or Accessory Manufacturer Data
    public let id: UUID
    
    /// Name from scan response.
    public let name: String
    
    /// Advertised service from scan response.
    public let service: ServiceType
}

public struct AccessoryScanResponse: Equatable, Hashable {
    
    public let name: String
    
    public let service: ServiceType
}

/// Paired accessory information.
public struct AccessoryInformation: Equatable, Hashable, Codable, Identifiable {
    
    /// Accessory identifier
    public let id: UUID
    
    /// Key for the paired accessory
    public let key: Key
    
    /// Accessory advertised service
    public let service: ServiceType
    
    /// Accessory type
    public let accessory: AccessoryType
    
    /// Accessory name
    public var name: String
}
