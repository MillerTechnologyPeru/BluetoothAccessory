//
//  Manufacturer.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

public struct ManufacturerCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .manufacturer) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}

// MARK: - Central

public extension CentralManager {
    
    /// Read manufacturer.
    func readManufacturer(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> String {
        let characteristic = try await read(ManufacturerCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read manufacturer.
    func readManufacturer() async throws -> String {
        let characteristic = try self.cache.characteristic(.manufacturer, service: .information)
        return try await self.central.readManufacturer(characteristic: characteristic)
    }
}

