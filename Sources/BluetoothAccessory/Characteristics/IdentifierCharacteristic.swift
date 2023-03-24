//
//  IdentifierCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public struct IdentifierCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .identifier) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: UUID = UUID()) {
        self.value = value
    }
    
    public var value: UUID
}

// MARK: - Central

public extension CentralManager {
    
    /// Read accessory identifier.
    func readIdentifier(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> UUID {
        let characteristic = try await read(IdentifierCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read accessory identifier.
    func readIdentifier() async throws -> UUID {
        let characteristic = try self.cache.characteristic(.identifier, service: .information)
        return try await self.central.readIdentifier(characteristic: characteristic)
    }
}
