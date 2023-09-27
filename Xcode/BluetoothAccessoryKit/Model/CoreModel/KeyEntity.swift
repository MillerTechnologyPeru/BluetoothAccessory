//
//  KeyEntity.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 9/26/23.
//

import Foundation
import BluetoothAccessory
import CoreModel

/// Key Entity
public struct KeyEntity: Equatable, Hashable, Identifiable, Codable, Sendable {
    
    public let id: UUID
    
    public let accessory: UUID
    
    public let created: Date
    
    public let name: String
    
    public let permission: PermissionType
    
    public let scheduleExpiry: Date?

    public let monday: Bool
    
    public let tuesday: Bool
    
    public let wednesday: Bool
    
    public let thursday: Bool
    
    public let friday: Bool
    
    public let saturday: Bool
    
    public let sunday: Bool
    
    public let intervalMin: UInt16
    
    public let intervalMax: UInt16
    
    public enum CodingKeys: String, CodingKey {
        
        case id
        case accessory
        case created
        case name
        case permission
        case scheduleExpiry
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
        case intervalMin
        case intervalMax
    }
}

// MARK: - Entity

extension KeyEntity: Entity {
    
    public static var entityName: EntityName { "Key" }
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .created : .date,
            .name: .string,
            .permission: .int16,
            .scheduleExpiry: .date,
            .monday: .bool,
            .tuesday: .bool,
            .wednesday: .bool,
            .thursday: .bool,
            .friday: .bool,
            .saturday: .bool,
            .sunday: .bool,
            .intervalMin: .bool,
            .intervalMax: .bool,
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .accessory : Relationship(
                id: .accessory,
                entity: KeyEntity.self,
                destination: AccessoryEntity.self,
                type: .toOne,
                inverseRelationship: .keys
            )
        ]
    }
}
