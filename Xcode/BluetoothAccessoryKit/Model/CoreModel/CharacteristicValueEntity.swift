//
//  CharacteristicValueEntity.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 9/26/23.
//

import Foundation
import Bluetooth
import BluetoothAccessory
import CoreModel

public struct CharacteristicValueEntity: Equatable, Hashable, Identifiable, Sendable {
    
    public var id: ID {
        .init(
            accessory: characteristic.accessory,
            service: characteristic.service,
            characteristic: characteristic.characteristic,
            index: index
        )
    }
    
    public let characteristic: CharacteristicEntity.ID
    
    public let index: UInt
    
    public let value: CharacteristicValue
    
    public enum CodingKeys: String, CodingKey {
        
        case id
        case index
        case characteristic
        case type
        case encoded
        case binaryValue
        case boolValue
        case dateValue
        case doubleValue
        case floatValue
        case intValue
        case stringValue
        case uuidValue
    }
}

// MARK: - Codable

extension CharacteristicValueEntity: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(ID.self, forKey: .id)
        let characteristic = try container.decode(CharacteristicEntity.ID.self, forKey: .characteristic)
        let index = try container.decode(UInt.self, forKey: .index)
        guard id.characteristic == characteristic.characteristic, id.accessory == characteristic.accessory, id.service == characteristic.service, id.index == index else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid identifier \(id)"))
        }
        self.index = index
        self.characteristic = characteristic
        let type = try container.decode(CharacteristicFormat.self, forKey: .type)
        switch type {
        case .bool:
            let value = try container.decode(Bool.self, forKey: .boolValue)
            self.value = .bool(value)
        case .data:
            let value = try container.decode(Data.self, forKey: .binaryValue)
            self.value = .data(value)
        case .date:
            let value = try container.decode(Date.self, forKey: .dateValue)
            self.value = .date(value)
        case .string:
            let value = try container.decode(String.self, forKey: .stringValue)
            self.value = .string(value)
        case .uuid:
            let value = try container.decode(UUID.self, forKey: .uuidValue)
            self.value = .uuid(value)
        case .float:
            let value = try container.decode(Float.self, forKey: .floatValue)
            self.value = .float(value)
        case .double:
            let value = try container.decode(Double.self, forKey: .doubleValue)
            self.value = .double(value)
        case .tlv8:
            let value = try container.decode(Data.self, forKey: .binaryValue)
            self.value = .data(value)
        case .int8:
            let value = try container.decode(Int8.self, forKey: .intValue)
            self.value = .int8(value)
        case .int16:
            let value = try container.decode(Int16.self, forKey: .intValue)
            self.value = .int16(value)
        case .int32:
            let value = try container.decode(Int32.self, forKey: .intValue)
            self.value = .int32(value)
        case .int64:
            let value = try container.decode(Int64.self, forKey: .intValue)
            self.value = .int64(value)
        case .uint8:
            let value = try container.decode(UInt8.self, forKey: .intValue)
            self.value = .uint8(value)
        case .uint16:
            let value = try container.decode(UInt16.self, forKey: .intValue)
            self.value = .uint16(value)
        case .uint32:
            let value = try container.decode(UInt32.self, forKey: .intValue)
            self.value = .uint32(value)
        case .uint64:
            let value = try container.decode(UInt64.self, forKey: .intValue)
            self.value = .uint64(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value.format, forKey: .type)
        try container.encode(value.encode(), forKey: .encoded)
        try container.encode(index, forKey: .index)
        try container.encode(characteristic, forKey: .characteristic)
        switch value {
        case let .bool(value):
            try container.encode(value, forKey: .boolValue)
        case let .data(value):
            try container.encode(value, forKey: .binaryValue)
        case let .date(value):
            try container.encode(value, forKey: .dateValue)
        case let .float(value):
            try container.encode(value, forKey: .floatValue)
        case let .double(value):
            try container.encode(value, forKey: .doubleValue)
        case let .string(value):
            try container.encode(value, forKey: .stringValue)
        case let .uuid(value):
            try container.encode(value, forKey: .uuidValue)
        case let .int8(value):
            try container.encode(value, forKey: .intValue)
        case let .int16(value):
            try container.encode(value, forKey: .intValue)
        case let .int32(value):
            try container.encode(value, forKey: .intValue)
        case let .int64(value):
            try container.encode(value, forKey: .intValue)
        case let .uint8(value):
            try container.encode(value, forKey: .intValue)
        case let .uint16(value):
            try container.encode(value, forKey: .intValue)
        case let .uint32(value):
            try container.encode(value, forKey: .intValue)
        case let .uint64(value):
            try container.encode(value, forKey: .intValue)
        case let .tlv8(value):
            try container.encode(value, forKey: .binaryValue)
        }
    }
}

// MARK: - Entity

extension CharacteristicValueEntity: Entity {
    
    public static var entityName: EntityName { "CharacteristicValue" }
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .index : .int16,
            .type : .int16,
            .encoded: .data,
            .binaryValue: .data,
            .boolValue: .bool,
            .dateValue: .date,
            .floatValue: .float,
            .doubleValue: .double,
            .intValue: .int64,
            .stringValue: .string,
            .uuidValue: .uuid
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .characteristic : Relationship(
                id: .characteristic,
                entity: CharacteristicValueEntity.self,
                destination: CharacteristicEntity.self,
                type: .toOne,
                inverseRelationship: .values
            )
        ]
    }
}

// MARK: - Supporting Types

extension CharacteristicValueEntity {
    
    public struct ID: Equatable, Hashable, Codable, Sendable {
        
        public let accessory: UUID
        
        public let service: BluetoothUUID
        
        public let characteristic: BluetoothUUID
        
        public let index: UInt
    }
}

extension CharacteristicValueEntity.ID: RawRepresentable {
    
    public init?(rawValue: String) {
        let components = rawValue.split(separator: "/", maxSplits: 4, omittingEmptySubsequences: true)
        guard components.count == 4,
              let accessory = UUID(uuidString: String(components[0])),
              let service = BluetoothUUID(rawValue: String(components[1])),
              let characteristic = BluetoothUUID(rawValue: String(components[2])),
              let index = UInt(components[3]) else {
            return nil
        }
        self.init(
            accessory: accessory,
            service: service,
            characteristic: characteristic,
            index: index
        )
    }
    
    public var rawValue: String {
        accessory.uuidString + "/" + service.rawValue + "/" + characteristic.rawValue + "/" + index.description
    }
}

extension CharacteristicValueEntity.ID: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}

extension CharacteristicValueEntity.ID: ObjectIDConvertible {
    
    public init?(objectID: ObjectID) {
        self.init(rawValue: objectID.rawValue)
    }
}
