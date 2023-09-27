//
//  CharacteristicEntity.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 9/25/23.
//

import Foundation
import Bluetooth
import BluetoothAccessory
import CoreModel

/// Characteristic Entity
public struct CharacteristicEntity: Equatable, Hashable, Identifiable, Codable, Sendable {
    
    public let id: ID
    
    public let accessory: UUID
    
    public let type: BluetoothUUID
    
    public let format: CharacteristicFormat
    
    public let unit: CharacteristicUnit?
    
    public let name: String
    
    public let service: BluetoothUUID
    
    public let isEncrypted: Bool
    
    public let isList: Bool
    
    public let isReadable: Bool
    
    public let isWritable: Bool
    
    public let isWriteWithoutResponse: Bool
    
    public var lastUpdate: Date?
    
    public var values: [CharacteristicValueEntity.ID]
    
    public enum CodingKeys: String, CodingKey {
        
        case id
        case accessory
        case type
        case format
        case unit
        case name
        case service
        case isEncrypted
        case isList
        case isReadable
        case isWritable
        case isWriteWithoutResponse
        case values
    }
}

// MARK: - Store

internal extension ModelStorage {
    
    func metadata(
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) async throws -> CharacteristicMetadata {
        let id = CharacteristicEntity.ID(
            accessory: accessory,
            service: service,
            characteristic: characteristic
        )
        guard let entity = try await self.fetch(CharacteristicEntity.self, for: id) else {
            throw BluetoothAccessoryError.metadataRequired(characteristic)
        }
        return CharacteristicMetadata(entity)
    }
    
    func characteristics(
        for accessory: UUID
    ) throws -> [CharacteristicCache] {
        []
    }
}

// MARK: - Entity

extension CharacteristicEntity: Entity {
    
    public static var entityName: EntityName { "Characteristic" }
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .type : .string,
            .format : .int16,
            .unit : .int16,
            .name : .string,
            .service : .string,
            .isEncrypted : .bool,
            .isList : .bool,
            .isReadable: .bool,
            .isWritable: .bool,
            .isWriteWithoutResponse: .bool
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .accessory : Relationship(
                id: .accessory,
                entity: CharacteristicEntity.self,
                destination: AccessoryEntity.self,
                type: .toOne,
                inverseRelationship: .characteristics
            ),
            .values : Relationship(
                id: .values,
                entity: CharacteristicEntity.self,
                destination: CharacteristicValueEntity.self,
                type: .toMany,
                inverseRelationship: .characteristic
            ),
        ]
    }
}

// MARK: - Supporting Types

extension CharacteristicEntity {
    
    public struct ID: Equatable, Hashable, Codable, Sendable {
        
        public let accessory: UUID
        
        public let service: BluetoothUUID
        
        public let characteristic: BluetoothUUID
    }
}

extension CharacteristicEntity.ID: RawRepresentable {
    
    public init?(rawValue: String) {
        let components = rawValue.split(separator: "/", maxSplits: 3, omittingEmptySubsequences: true)
        guard components.count == 3,
              let accessory = UUID(uuidString: String(components[0])),
              let service = BluetoothUUID(rawValue: String(components[1])),
              let characteristic = BluetoothUUID(rawValue: String(components[2])) else {
            return nil
        }
        self.init(accessory: accessory, service: service, characteristic: characteristic)
    }
    
    public var rawValue: String {
        accessory.uuidString + "/" + service.rawValue + "/" + characteristic.rawValue
    }
}

extension CharacteristicEntity.ID: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}

extension CharacteristicEntity.ID: ObjectIDConvertible {
    
    public init?(objectID: ObjectID) {
        self.init(rawValue: objectID.rawValue)
    }
}
