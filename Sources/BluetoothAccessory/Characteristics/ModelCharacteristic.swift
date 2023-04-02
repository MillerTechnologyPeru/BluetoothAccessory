//
//  ModelCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

public struct ModelCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .model) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}

// MARK: - Central

public extension CentralManager {
    
    /// Read model.
    func readModel(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> String {
        let characteristic = try await read(ModelCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read model.
    func readModel() async throws -> String {
        let characteristic = try self.cache.characteristic(.model, service: .information)
        return try await self.central.readModel(characteristic: characteristic)
    }
}
