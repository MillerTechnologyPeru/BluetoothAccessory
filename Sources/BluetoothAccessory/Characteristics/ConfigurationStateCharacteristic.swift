//
//  ConfigurationStateCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/27/23.
//

import Foundation
import Bluetooth
import GATT

public struct ConfigurationStateCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .isConfigured) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: Bool) {
        self.value = value
    }
    
    public var value: Bool
}

// MARK: - Central

public extension CentralManager {
    
    /// Read accessory name.
    func readConfiguredState(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> Bool {
        let characteristic = try await read(ConfigurationStateCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read accessory name.
    func readConfiguredState() async throws -> Bool {
        let characteristic = try self.cache.characteristic(.isConfigured, service: .authentication)
        return try await self.central.readConfiguredState(characteristic: characteristic)
    }
}
