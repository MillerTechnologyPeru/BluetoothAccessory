//
//  DescriptorType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
#if canImport(BluetoothGATT)
import BluetoothGATT
#endif

/// Descriptor Type
public enum DescriptorType: UInt16, Codable, CaseIterable {
    
    /// Data format of characteristic value. Required. Read-only.
    case format
    
    /// Unit type. Optional. Read-only.
    case unit
    
    /// Type of encryption used. Required. Read-only.
    case encryption
}

public extension UUID {
    
    init(descriptor: DescriptorType) {
        self.init(bluetoothAccessory: (0x0003, descriptor.rawValue))
    }
}

public extension BluetoothUUID {
    
    init(descriptor: DescriptorType) {
        self.init(uuid: .init(descriptor: descriptor))
    }
}

/// Accessory Descriptor
public enum AccessoryDescriptor: Equatable, Hashable, Codable {
    
    /// Data format of characteristic value. Required. Read-only.
    case format(CharacteristicFormat)
    
    /// Unit type. Optional. Read-only.
    case unit(CharacteristicUnit)
    
    /// Type of encryption used. Required. Read-only.
    case encryption(CharacteristicEncryption)
}

public extension AccessoryDescriptor {
    
    var type: DescriptorType {
        switch self {
        case .format:
            return .format
        case .unit:
            return .unit
        case .encryption:
            return .encryption
        }
    }
    
    func encode() -> Data {
        switch self {
        case .format(let value):
            return CharacteristicValue.uint8(value.rawValue).encode()
        case .unit(let value):
            return CharacteristicValue.uint8(value.rawValue).encode()
        case .encryption(let value):
            return CharacteristicValue.uint8(value.rawValue).encode()
        }
    }
}

#if canImport(BluetoothGATT)
public extension GATTAttribute.Descriptor {
    
    init(_ descriptor: AccessoryDescriptor) {
        self.init(
            uuid: BluetoothUUID(descriptor: descriptor.type),
            value: descriptor.encode(),
            permissions: [.read]
        )
    }
}

public extension GATTCharacteristicFormatType {
    
    init(bluetoothAccessory: CharacteristicFormat) {
        switch bluetoothAccessory {
        case .tlv8:
            self = .struct
        case .data:
            self = .struct
        case .string:
            self = .utf8s
        case .date:
            self = .float64
        case .uuid:
            self = .uint128
        case .bool:
            self = .boolean
        case .int8:
            self = .sint8
        case .int16:
            self = .sint16
        case .int32:
            self = .sint32
        case .int64:
            self = .sint64
        case .uint8:
            self = .uint8
        case .uint16:
            self = .uint16
        case .uint32:
            self = .uint32
        case .uint64:
            self = .uint64
        case .float:
            self = .float32
        case .double:
            self = .float64
        }
    }
}

#endif
