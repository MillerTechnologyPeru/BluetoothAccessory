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

// MARK: - Central

public extension CentralManager {
    
    /// Read the list of keys.
    func readKeys(
        characteristic notifyCharacteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> AsyncThrowingMapSequence<AsyncThrowingStream<Data, Error>, KeysCharacteristic> {
        return try await readList(
            KeysCharacteristic.self,
            characteristic: notifyCharacteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        )
    }
}

public extension GATTConnection {
    
    /// Read the list of keys.
    func readKeys(key: Credential) async throws -> AsyncThrowingMapSequence<AsyncThrowingStream<Data, Error>, KeysCharacteristic> {
        return try await self.central.readKeys(
            characteristic: cache.characteristic(.keys, service: .authentication),
            service: BluetoothUUID(service: .authentication),
            cryptoHash: cache.characteristic(.cryptoHash, service: .authentication),
            authentication: cache.characteristic(.authenticate, service: .authentication),
            key: key
        )
    }
}
