//
//  Store.swift
//
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import CloudKit
import KeychainAccess

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
public final class AccessoryManager: ObservableObject {
    
    // MARK: - Properties
    
    public let configuration: Configuration
    
    @Published
    public internal(set) var state: DarwinBluetoothState = .unknown
    
    @Published
    public internal(set) var isScanning = false
    
    @Published
    public internal(set) var peripherals = [Peripheral: Bool]()
    
    /// Discovered accessories with advertised identifiers.
    @Published
    public internal(set) var accessoryPeripherals = [UUID: AccessoryPeripheral]()
    
    /// Discovered accessory scan responses.
    @Published
    public internal(set) var scanResponses = [Peripheral: AccessoryScanResponse]()
    
    /// All discovered devices.
    @Published
    public internal(set) var scanResults = [Peripheral: ScanDataCache]()
    
    /// Keys of paired devices.
    @Published
    public internal(set) var keys = [UUID: Key]()
    
    @Published
    public internal(set) var characteristics = [Peripheral: [Characteristic: CharacteristicCache]]()
    
    internal lazy var central = loadBluetooth(options: configuration.central)
    
    internal var scanStream: AsyncCentralScan<Central>?
    
    internal lazy var cloudContainer = loadCloudContainer(identifier: configuration.cloud)
    
    #if os(iOS)
    internal lazy var keyValueStore: NSUbiquitousKeyValueStore = .default
    #endif
    
    internal var keyValueStoreObserver: NSObjectProtocol?
    
    // MARK: - Initialization
    
    deinit {
        // stop observing
        if let observer = keyValueStoreObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    public init(
        configuration: Configuration
    ) {
        self.configuration = configuration
    }
}

// MARK: - Supporting Types

public extension AccessoryManager {
    
    /// Configuration
    struct Configuration {
        
        public var central: NativeCentral.Options
        
        public var cloud: String?
        
        public init(central: NativeCentral.Options, cloud: String? = nil) {
            self.central = central
            self.cloud = cloud
        }
    }
}
