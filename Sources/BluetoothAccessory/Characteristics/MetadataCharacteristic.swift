//
//  MetadataCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT
import TLVCoding

/// Encrypted list of characteristic metadata.
public struct MetadataCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .metadata) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.list] }
    
    public init(value: CharacteristicMetadata) {
        self.value = value
    }
    
    public var value: CharacteristicMetadata
}

// MARK: - Supporting Types

public struct CharacteristicMetadata: Equatable, Hashable, Codable {
    
    public let type: BluetoothUUID
    
    public let properties: BitMaskOptionSet<CharacteristicProperty>
    
    public let format: CharacteristicFormat
    
    public let unit: CharacteristicUnit?
    
    public init(
        type: BluetoothUUID,
        properties: BitMaskOptionSet<CharacteristicProperty>,
        format: CharacteristicFormat,
        unit: CharacteristicUnit? = nil
    ) {
        self.type = type
        self.properties = properties
        self.format = format
        self.unit = unit
    }
}

extension CharacteristicMetadata: Identifiable {
    
    public var id: BluetoothUUID {
        type
    }
}

extension CharacteristicMetadata: CharacteristicTLVCodable { }

public extension CharacteristicMetadata {
    
    init<T: AccessoryCharacteristic>(characteristic: T.Type) {
        self.init(
            type: characteristic.type,
            properties: characteristic.properties,
            format: characteristic.Value.characteristicFormat,
            unit: characteristic.unit
        )
    }
}

public extension CharacteristicMetadata {
    
    init(characteristic: CharacteristicType) {
        let accessoryType = characteristic.accessoryType
        self.init(
            type: accessoryType.type,
            properties: accessoryType.properties,
            format: accessoryType.format,
            unit: accessoryType.unit
        )
    }
}

public extension AccessoryCharacteristic {
    
    static var metadata: CharacteristicMetadata {
        .init(characteristic: self)
    }
}
