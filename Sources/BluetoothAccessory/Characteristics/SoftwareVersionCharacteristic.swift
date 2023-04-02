//
//  SoftwareVersionCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

public struct SoftwareVersionCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .softwareVersion) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}

// MARK: - Central

public extension CentralManager {
    
    /// Read manufacturer.
    func readSoftwareVersion(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> String {
        let characteristic = try await read(SoftwareVersionCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read manufacturer.
    func readSoftwareVersion() async throws -> String {
        let characteristic = try self.cache.characteristic(.softwareVersion, service: .information)
        return try await self.central.readSoftwareVersion(characteristic: characteristic)
    }
}
