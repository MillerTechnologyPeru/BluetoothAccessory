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
public final class AccessoryManager: ObservableObject {
    
    // MARK: - Properties
    
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
    
    internal lazy var central = loadBluetooth()
    
    internal var scanStream: AsyncCentralScan<Central>?
    
    // MARK: - Initialization
    
    public static let shared = AccessoryManager()
    
    private init() {
        observeBluetoothState()
        observePeripherals()
    }
}
