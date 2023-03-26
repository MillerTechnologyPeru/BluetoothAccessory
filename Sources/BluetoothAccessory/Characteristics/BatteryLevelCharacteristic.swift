//
//  BatteryLevelCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

/// Accessory battery level value.
public struct BatteryLevelCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .batteryLevel) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .percentage }
    
    public init(value: UInt8 = 100) {
        assert(value <= 100)
        self.value = value
    }
    
    public var value: UInt8 {
        didSet {
            // Validate battery level under 100%
            assert(value <= 100, "Battery level must not exceed 100%")
        }
    }
}

// MARK: - Central

public extension CentralManager {
    
    /// Read battery level value.
    func readBatteryLevel(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> UInt8 {
        let characteristic = try await read(BatteryLevelCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read battery level value.
    func readBatteryLevel() async throws -> UInt8 {
        let characteristic = try self.cache.characteristic(.batteryLevel, service: .battery)
        return try await self.central.readBatteryLevel(characteristic: characteristic)
    }
}
