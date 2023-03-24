//
//  AccessoryTypeCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/2/23.
//

import Foundation
import Bluetooth
import GATT

public struct AccessoryTypeCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .accessoryType) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: AccessoryType) {
        self.value = value
    }
    
    public var value: AccessoryType
}

// MARK: - Central

public extension CentralManager {
    
    /// Read accessory type.
    func readAccessoryType(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> AccessoryType {
        let characteristic = try await read(AccessoryTypeCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read accessory type.
    func readAccessoryType() async throws -> AccessoryType {
        let characteristic = try self.cache.characteristic(.accessoryType, service: .information)
        return try await self.central.readAccessoryType(characteristic: characteristic)
    }
}
