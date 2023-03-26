//
//  BatteryVoltageCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Battery Voltage Characteristic
public struct BatteryVoltageCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .batteryVoltage) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .volts }
    
    public init(value: Float) {
        self.value = value
    }
    
    public var value: Float
}

// MARK: - Central

public extension CentralManager {
    
    /// Read battery voltage.
    func readBatteryVoltage(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> Float {
        let characteristic = try await read(BatteryVoltageCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read battery voltage.
    func readBatteryVoltage() async throws -> Float {
        let characteristic = try self.cache.characteristic(.batteryVoltage, service: .battery)
        return try await self.central.readBatteryVoltage(characteristic: characteristic)
    }
}
