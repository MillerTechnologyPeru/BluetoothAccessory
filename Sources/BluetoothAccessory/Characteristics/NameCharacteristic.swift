//
//  NameCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public struct NameCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .name) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}

// MARK: - Central

public extension CentralManager {
    
    /// Read accessory name.
    func readName(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> String {
        let characteristic = try await read(NameCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read accessory name.
    func readName() async throws -> String {
        let characteristic = try self.cache.characteristic(.name, service: .information)
        return try await self.central.readName(characteristic: characteristic)
    }
}
