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
    
    public typealias Central = NativeCentral
    
    public typealias Peripheral = Central.Peripheral
    
    public typealias ScanData = GATT.ScanData<Central.Peripheral, Central.Advertisement>
    
    public typealias Service = GATT.Service<Central.Peripheral, Central.AttributeID>
    
    public typealias Characteristic = GATT.Characteristic<Central.Peripheral, Central.AttributeID>
    
    public typealias Descriptor = GATT.Descriptor<Central.Peripheral, Central.AttributeID>
    
    public typealias ScanDataCache = BluetoothAccessoryKit.ScanDataCache<Central.Peripheral, Central.Advertisement>
    
    public typealias AccessoryPeripheral = BluetoothAccessoryKit.AccessoryPeripheral<Central.Peripheral>
    
    // MARK: - Properties
    
    @Published
    public private(set) var state: DarwinBluetoothState = .unknown
    
    @Published
    public private(set) var isScanning = false
    
    /// Discovered accessories with advertised identifiers.
    @Published
    public private(set) var accessoryPeripherals = [UUID: AccessoryPeripheral]()
    
    /// Discovered accessory scan responses.
    @Published
    public private(set) var scanResponses = [Peripheral: AccessoryScanResponse]()
    
    /// All discovered devices.
    @Published
    public private(set) var scanResults = [Peripheral: ScanDataCache]()
    
    /// Currently connected devices.
    @Published
    public private(set) var connected = Set<Peripheral>()
    
    /// Keys of paired devices.
    @Published
    public private(set) var keys = [UUID: Key]()
    
    internal lazy var central = Central()
    
    private var scanStream: AsyncCentralScan<Central>?
    
    // Cached Service UUID for lookup
    internal lazy var serviceTypes: [BluetoothUUID: ServiceType] = {
        var serviceTypes = [BluetoothUUID: ServiceType]()
        serviceTypes.reserveCapacity(ServiceType.allCases.count)
        for service in ServiceType.allCases {
            let uuid = BluetoothUUID(service: service)
            serviceTypes[uuid] = service
        }
        assert(serviceTypes.count == ServiceType.allCases.count)
        return serviceTypes
    }()
    
    // MARK: - Initialization
    
    public static let shared = AccessoryStore()
    
    private init() {
        central.log = { [unowned self] in self.log("📲 Central: " + $0) }
        observeBluetoothState()
    }
    
    // MARK: - Subscript
    
    /// Bluetooth ``Peripheral`` for the Accessory with the specified ID.
    public subscript (peripheral id: UUID) -> Peripheral? {
        accessoryPeripherals[id]?.peripheral
    }
    
    /// Service Type for the specified ``BluetoothUUID``
    internal subscript (service uuid: BluetoothUUID) -> ServiceType? {
        serviceTypes[uuid]
    }
    
    /// Get the discovered accessory with advertised identifiers for the specified peripheral.
    public subscript (accessory peripheral: Peripheral) -> AccessoryPeripheral? {
        accessoryPeripherals.values.first(where: { $0.peripheral == peripheral })
    }
    
    /// Get the discovered beacon for the specified peripheral.
    public subscript (beacon peripheral: Peripheral) -> AccessoryBeacon? {
        scanResults[peripheral]?.beacon.flatMap { AccessoryBeacon(beacon: $0) }
    }
    
    /// Get the discovered manufacturer data for the specified peripheral.
    public subscript (manufacturerData peripheral: Peripheral) -> AccessoryManufacturerData? {
        scanResults[peripheral]?.manufacturerData.flatMap { AccessoryManufacturerData(manufacturerData: $0) }
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
    
    public func scan(
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
    
    public func stopScanning() {
        scanStream?.stop()
        scanStream = nil
        isScanning = false
    }
    
    private func found(_ scanData: ScanData) async -> Bool {
        
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


// MARK: - Supporting Types

public struct ScanDataCache <Peripheral: Peer, Advertisement: AdvertisementData>: Equatable, Hashable {
    
    public internal(set) var scanData: GATT.ScanData<Peripheral, Advertisement>
    
    /// GAP or advertised name
    public internal(set) var name: String?
    
    /// Advertised name
    public internal(set) var advertisedName: String?
    
    public internal(set) var manufacturerData: GATT.ManufacturerSpecificData?
    
    /// This value is available if the broadcaster (peripheral) provides its Tx power level in its advertising packet.
    /// Using the RSSI value and the Tx power level, it is possible to calculate path loss.
    public internal(set) var txPowerLevel: Double?
    
    /// Service-specific advertisement data.
    public internal(set) var serviceData = [BluetoothUUID: Data]()
    
    /// An array of service UUIDs
    public internal(set) var serviceUUIDs = Set<BluetoothUUID>()
    
    /// An array of one or more ``BluetoothUUID``, representing Service UUIDs.
    public internal(set) var solicitedServiceUUIDs = Set<BluetoothUUID>()
    
    /// An array of one or more ``BluetoothUUID``, representing Service UUIDs that were found in the “overflow” area of the advertisement data.
    public internal(set) var overflowServiceUUIDs = Set<BluetoothUUID>()
    
    /// Advertised iBeacon
    public internal(set) var beacon: AppleBeacon?
    
    internal init(scanData: GATT.ScanData<Peripheral, Advertisement>) {
        self.scanData = scanData
        self += scanData
    }
    
    internal static func += (cache: inout ScanDataCache, scanData: GATT.ScanData<Peripheral, Advertisement>) {
        cache.scanData = scanData
        cache.advertisedName = scanData.advertisementData.localName
        if cache.name == nil {
            cache.name = scanData.advertisementData.localName
        }
        cache.txPowerLevel = scanData.advertisementData.txPowerLevel
        if let beacon = scanData.advertisementData.beacon {
            cache.beacon = beacon
        } else {
            cache.manufacturerData = scanData.advertisementData.manufacturerData
        }
        for serviceUUID in scanData.advertisementData.serviceUUIDs ?? [] {
            cache.serviceUUIDs.insert(serviceUUID)
        }
        for (serviceUUID, serviceData) in scanData.advertisementData.serviceData ?? [:] {
            cache.serviceData[serviceUUID] = serviceData
        }
    }
}

extension ScanDataCache: Identifiable {
    
    public var id: Peripheral.ID {
        scanData.id
    }
}
