//
//  BatteryChargingCurrentCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Battery Charging Current Characteristic
public struct BatteryChargingCurrentCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .batteryChargingCurrent) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .amps }
    
    public init(value: UInt8) {
        self.value = value
    }
    
    public var value: UInt8
}

// MARK: - Central

public extension CentralManager {
    
    /// Read Battery Charging Current value.
    func readBatteryChargingCurrent(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> UInt8 {
        let characteristic = try await read(BatteryChargingCurrentCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read Battery Charging Current value.
    func readBatteryChargingCurrent() async throws -> UInt8 {
        let characteristic = try self.cache.characteristic(.batteryChargingCurrent, service: .battery)
        return try await self.central.readBatteryChargingCurrent(characteristic: characteristic)
    }
}
