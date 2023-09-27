//
//  AccessoryEntity.swift
//
//
//  Created by Alsey Coleman Miller on 9/24/23.
//

import Foundation
import Bluetooth
import BluetoothAccessory
import CoreModel
import AppIntents

/// Accessory Entity
public struct AccessoryEntity: Equatable, Hashable, Identifiable, Codable, Sendable {
    
    public let id: UUID
    
    /// Accessory name
    public var name: String
    
    /// Accessory type
    public let type: AccessoryType
    
    /// Accessory advertised service
    public var service: ServiceType
    
    /// Manufacturer Name
    public var manufacturer: String
    
    public var serialNumber: String
    
    public var model: String
    
    public var softwareVersion: String
    
    public var characteristics: [CharacteristicEntity.ID]
    
    public var keys: [UUID]
    
    public var pendingKeys: [UUID]
    
    public enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case type
        case service
        case manufacturer
        case serialNumber
        case model
        case softwareVersion
        case characteristics
        case keys
        case pendingKeys
    }
}

public extension AccessoryEntity {
    
    init(
        _ value: AccessoryInformation,
        characteristics: [CharacteristicEntity.ID] = [],
        keys: [UUID] = [],
        pendingKeys: [UUID] = []
    ) {
        self.id = value.id
        self.name = value.name
        self.type = value.accessory
        self.service = value.service
        self.manufacturer = value.manufacturer
        self.serialNumber = value.serialNumber
        self.model = value.model
        self.softwareVersion = value.softwareVersion
        self.characteristics = characteristics
        self.keys = keys
        self.pendingKeys = pendingKeys
    }
}

internal extension AccessoryEntity {
    
    mutating func update(_ value: AccessoryInformation) {
        self = .init(value, characteristics: self.characteristics, keys: self.keys, pendingKeys: self.pendingKeys)
    }
}

// MARK: - Entity

extension AccessoryEntity: Entity {
    
    public static var entityName: EntityName { "Accessory" }
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .name : .string,
            .type : .int32,
            .service : .int32,
            .manufacturer : .string,
            .serialNumber : .string,
            .model        : .string,
            .softwareVersion : .string
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .characteristics : Relationship(
                id: .characteristics,
                entity: AccessoryEntity.self,
                destination: CharacteristicEntity.self,
                type: .toMany,
                inverseRelationship: .accessory
            ),
            .keys : Relationship(
                id: .keys,
                entity: AccessoryEntity.self,
                destination: KeyEntity.self,
                type: .toMany,
                inverseRelationship: .accessory
            ),
            .pendingKeys : Relationship(
                id: .pendingKeys,
                entity: AccessoryEntity.self,
                destination: NewKeyEntity.self,
                type: .toMany,
                inverseRelationship: .accessory
            ),
        ]
    }
}
