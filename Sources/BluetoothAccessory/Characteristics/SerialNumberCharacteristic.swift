//
//  SerialNumberCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

public struct SerialNumberCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .serialNumber) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}

// MARK: - Central

public extension CentralManager {
    
    /// Read serial number.
    func readSerialNumber(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> String {
        let characteristic = try await read(SerialNumberCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read serial number.
    func readSerialNumber() async throws -> String {
        let characteristic = try self.cache.characteristic(.serialNumber, service: .information)
        return try await self.central.readSerialNumber(characteristic: characteristic)
    }
}
