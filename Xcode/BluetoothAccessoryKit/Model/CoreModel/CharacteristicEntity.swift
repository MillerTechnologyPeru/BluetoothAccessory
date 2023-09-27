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
    
    public var lastUpdate: Date
    
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
        case lastUpdate
        case values
    }
}

public extension CharacteristicEntity {
    
    var properties: BitMaskOptionSet<BluetoothAccessory.CharacteristicProperty> {
        var properties = BitMaskOptionSet<BluetoothAccessory.CharacteristicProperty>()
        if isReadable {
            properties.insert(.read)
        }
        if isWritable {
            properties.insert(.write)
        }
        if isWriteWithoutResponse {
            properties.insert(.writeWithoutResponse)
        }
        if isEncrypted {
            properties.insert(.encrypted)
        }
        if isList {
            properties.insert(.list)
        }
        return properties
    }
}

internal extension CharacteristicEntity {
    
    init(
        metadata: CharacteristicMetadata,
        accessory: UUID,
        service: BluetoothUUID,
        lastUpdate: Date = Date(),
        values: [CharacteristicValueEntity.ID] = []
    ) {
        self.id = .init(accessory: accessory, service: service, characteristic: metadata.type)
        self.accessory = accessory
        self.service = service
        self.type = metadata.type
        self.format = metadata.format
        self.unit = metadata.unit
        self.name = metadata.name
        self.lastUpdate = lastUpdate
        self.values = values
        self.isReadable = metadata.properties.contains(.read)
        self.isWritable = metadata.properties.contains(.write)
        self.isWriteWithoutResponse = metadata.properties.contains(.writeWithoutResponse)
        self.isEncrypted = metadata.properties.contains(.encrypted)
        self.isList = metadata.properties.contains(.list)
    }
    
    mutating func update(metadata: CharacteristicMetadata) {
        self = .init(metadata: metadata, accessory: accessory, service: service, lastUpdate: Date(), values: values)
    }
}

internal extension CharacteristicCache {
    
    init<Storage: ModelStorage>(
        _ value: CharacteristicEntity,
        storage: Storage
    ) async throws {
        var values = [CharacteristicValueEntity]()
        values.reserveCapacity(value.values.count)
        for id in value.values {
            guard let valueEntity = try await storage.fetch(CharacteristicValueEntity.self, for: id) else {
                assertionFailure()
                continue
            }
            values.append(valueEntity)
        }
        let cachedValue: CharacteristicCache.Value?
        if value.isList {
            cachedValue = .list(values.map { $0.value })
        } else {
            cachedValue = values.first.flatMap({ .single($0.value) })
        }
        self.init(
            accessory: value.accessory,
            service: value.service,
            metadata: .init(value),
            value: cachedValue,
            updated: value.lastUpdate
        )
    }
}

internal extension CharacteristicMetadata {
    
    init(_ value: CharacteristicEntity) {
        self.init(
            type: value.type,
            name: value.name,
            properties: value.properties,
            format: value.format,
            unit: value.unit
        )
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
    ) async throws -> [CharacteristicCache] {
        let predicate = FetchRequest.Predicate.comparison(.init(
            left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.accessory.rawValue)),
            right: .relationship(.toOne(ObjectID(accessory))))
        )
        let entities = try await fetch(CharacteristicEntity.self, predicate: predicate)
        var cachedValues = [CharacteristicCache]()
        cachedValues.reserveCapacity(entities.count)
        for entity in entities {
            let cache = try await CharacteristicCache(entity, storage: self)
            cachedValues.append(cache)
        }
        return cachedValues
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
