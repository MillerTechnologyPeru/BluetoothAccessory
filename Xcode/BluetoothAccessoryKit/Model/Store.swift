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
    public internal(set) var state: DarwinBluetoothState = .unknown
    
    @Published
    public internal(set) var isScanning = false
    
    /// Discovered accessories with advertised identifiers.
    @Published
    public internal(set) var accessoryPeripherals = [UUID: AccessoryPeripheral]()
    
    /// Discovered accessory scan responses.
    @Published
    public internal(set) var scanResponses = [Peripheral: AccessoryScanResponse]()
    
    /// All discovered devices.
    @Published
    public internal(set) var scanResults = [Peripheral: ScanDataCache]()
    
    /// Currently connected devices.
    @Published
    public internal(set) var connected = Set<Peripheral>()
    
    /// Keys of paired devices.
    @Published
    public internal(set) var keys = [UUID: Key]()
    
    internal lazy var central = Central()
    
    internal var scanStream: AsyncCentralScan<Central>?
    
    // Cached Service UUID for lookup
    internal lazy var serviceTypes = loadServiceTypes()
    
    // MARK: - Initialization
    
    public static let shared = AccessoryStore()
    
    private init() {
        loadBluetooth()
    }
}

// MARK: - Private Methods

private extension AccessoryStore {
    
    func loadServiceTypes() -> [BluetoothUUID: ServiceType] {
        var serviceTypes = [BluetoothUUID: ServiceType]()
        serviceTypes.reserveCapacity(ServiceType.allCases.count)
        for service in ServiceType.allCases {
            let uuid = BluetoothUUID(service: service)
            serviceTypes[uuid] = service
        }
        assert(serviceTypes.count == ServiceType.allCases.count)
        return serviceTypes
    }
}
