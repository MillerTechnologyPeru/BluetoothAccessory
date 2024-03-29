//
//  Store.swift
//
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Combine
import CoreData
import CloudKit
import Contacts
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

/// Accessory Manager
@MainActor
public final class AccessoryManager: ObservableObject {
    
    // MARK: - Properties
    
    /// Accessory Manager Configuration
    public let configuration: Configuration
    
    @Published
    public internal(set) var state: DarwinBluetoothState = .unknown
    
    public var isScanning: Bool {
        scanStream != nil
    }
    
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
    
    /// Paired devices.
    @Published
    public internal(set) var cache = [UUID: PairedAccessory]()
    
    internal lazy var central = loadBluetooth()
    
    internal var centralObserver: AnyCancellable?
    
    @Published
    internal var scanStream: AsyncCentralScan<Central>?
    
    internal lazy var keychain = loadKeychain()
    
    public lazy var preferences = Preferences(suiteName: configuration.appGroup)!
    
    internal lazy var fileManager = FileManager()
    
    internal lazy var containerURL = loadContainerURL()
    
    public lazy var cloudContainer = loadCloudContainer()
    
    #if canImport(CoreSpotlight) && os(iOS) || os(macOS)
    internal lazy var spotlight = loadSpotlight()
    #endif
    
    #if os(iOS) && !APPCLIP
    internal lazy var keyValueStore: NSUbiquitousKeyValueStore = .default
    #endif
    
    internal var keyValueStoreObserver: NSObjectProtocol?
    
    internal lazy var contactStore = loadContacts()
    
    public lazy var persistentContainer = loadPersistentContainer()
    
    public lazy var managedObjectContext = loadViewContext()
    
    internal lazy var backgroundContext = loadBackgroundContext()
    
    @Published
    internal var persistentStoreState: PersistentStoreState = .uninitialized
    
    // MARK: - Initialization
    
    deinit {
        // stop observing
        self.centralObserver?.cancel()
        if let observer = keyValueStoreObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// Initialize Accessory Maneger with the speicified configuration.
    public init(
        configuration: Configuration
    ) {
        self.configuration = configuration
        let _ = try! loadCache()
    }
}

// MARK: - Supporting Types

public extension AccessoryManager {
    
    /// Configuration
    struct Configuration {
        
        public var central: NativeCentral.Options
                
        public var appGroup: String
        
        public var cloud: String?
        
        public var keychain: (service: String, group: String)
                
        public init(
            central: NativeCentral.Options,
            appGroup: String,
            keychain: (service: String, group: String),
            cloud: String? = nil
        ) {
            self.central = central
            self.cloud = cloud
            self.keychain = keychain
            self.appGroup = appGroup
        }
    }
}

public extension AccessoryManager.Configuration {
    
    static var `default`: AccessoryManager.Configuration {
        AccessoryManager.Configuration(
            central: NativeCentral.Options(
                showPowerAlert: true
            ),
            appGroup: "group.com.colemancda.BluetoothAccessory",
            keychain: (
                service: "com.colemancda.BluetoothAccessory",
                group: "4W79SG34MW.com.colemancda.BluetoothAccessory"
            ),
            cloud: "iCloud.com.colemancda.BluetoothAccessory"
        )
    }
}
