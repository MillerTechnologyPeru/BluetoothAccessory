//
//  KeysCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT
import TLVCoding

/// Encrypted list of keys.
public struct KeysCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .keys) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.encrypted, .list] }
    
    public init(value: Item) {
        self.value = value
    }
    
    public var value: Item
}

public extension KeysCharacteristic {
    
    enum Item: Equatable, Hashable {
        
        case key(Key)
        case newKey(NewKey)
        
        public var id: UUID {
            switch self {
            case let .key(key):
                return key.id
            case let .newKey(newKey):
                return newKey.id
            }
        }
    }
}

extension KeysCharacteristic.Item: CharacteristicTLVCodable {
    
    internal enum CodingKeys: UInt8, TLVCodingKey, CaseIterable {
        
        case type = 0x00
        case key = 0x01
        
        var stringValue: String {
            switch self {
            case .type: return "type"
            case .key: return "key"
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(KeyType.self, forKey: .type)
        switch type {
        case .key:
            let key = try container.decode(Key.self, forKey: .key)
            self = .key(key)
        case .newKey:
            let newKey = try container.decode(NewKey.self, forKey: .key)
            self = .newKey(newKey)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .key(key):
            try container.encode(KeyType.key, forKey: .type)
            try container.encode(key, forKey: .key)
        case let .newKey(newKey):
            try container.encode(KeyType.newKey, forKey: .type)
            try container.encode(newKey, forKey: .key)
        }
    }
}
