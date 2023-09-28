//
//  CharacteristicEntityQuery.swift
//  BluetoothCharacteristicApp
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit
import CoreModel

// MARK: - EntityQuery

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct CharacteristicEntityQuery: EntityQuery {
    
    let manager: AccessoryManager
    
    init(manager: AccessoryManager) {
        self.manager = manager
    }
    
    init() {
        self.init(manager: BluetoothAccessoryApp.accessoryManager)
    }
    
    @MainActor
    func entities(for identifiers: [CharacteristicAppEntity.ID]) throws -> [CharacteristicAppEntity] {
        return try entities(for: identifiers.map { ObjectID($0) })
    }
    
    func suggestedEntities() -> [CharacteristicAppEntity] { [] }
}

// MARK: - EntityPropertyQuery

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicEntityQuery: EntityPropertyQuery {
    
    @MainActor
    func entities(
        matching predicates: [CharacteristicEntityQuery.Predicate],
        mode: ComparatorMode,
        sortedBy sortDescriptors: [Sort<CharacteristicAppEntity>],
        limit: Int?
    ) throws -> [CharacteristicAppEntity] {
        guard predicates.isEmpty == false, mode == .and || predicates.count == 1 else {
            return []
        }
        var subpredicates = [CoreModel.FetchRequest.Predicate]()
        subpredicates.reserveCapacity(predicates.count)
        var accessory: UUID?
        for predicate in predicates {
            guard let characteristicPredicate = CharacteristicEntity.Predicate(predicate) else {
                return [] // invalid query
            }
            let comparison = CoreModel.FetchRequest.Predicate.Comparison(characteristicPredicate)
            // check if filtering by accessory
            switch predicate {
            case let .accessoryEqualTo(uuid):
                guard accessory == nil else {
                    return []
                }
                accessory = uuid
            default:
                break
            }
            subpredicates.append(.comparison(comparison))
        }
        guard let accessory else {
            return []
        }
        let predicate: CoreModel.FetchRequest.Predicate
        if subpredicates.count > 1 {
            predicate = .compound(.init(mode: mode, subpredicates: subpredicates))
        } else {
            assert(subpredicates.isEmpty == false)
            predicate = subpredicates.first ?? .value(false)
        }
        let fetchRequest = CoreModel.FetchRequest(
            entity: CharacteristicEntity.entityName,
            sortDescriptors: sortDescriptors.map { sortDescriptor(for: $0) },
            predicate: predicate,
            fetchLimit: limit ?? 0
        )
        let objectIDs = try manager.managedObjectContext.fetchID(fetchRequest)
        return try entities(for: objectIDs)
    }
    
    static var properties = EntityQueryProperties<CharacteristicAppEntity, CharacteristicEntityQuery.Predicate> {
        Property(\CharacteristicAppEntity.$name) {
            EqualToComparator { .nameEqualTo($0) }
            ContainsComparator { .nameContains($0) }
        }
        Property(\CharacteristicAppEntity.$type) {
            EqualToComparator { .characteristicTypeEqualTo($0) }
        }
        Property(\CharacteristicAppEntity.$accessory) {
            EqualToComparator { .accessoryEqualTo($0.id) }
        }
        Property(\CharacteristicAppEntity.$service) {
            EqualToComparator { .serviceTypeEqualTo($0) }
        }
        Property(\CharacteristicAppEntity.$format) {
            EqualToComparator { .formatEqualTo($0) }
        }
        Property(\CharacteristicAppEntity.$unit) {
            EqualToComparator { .unitEqualTo($0) }
        }
    }
    
    static var sortingOptions = SortingOptions {
        SortableBy(\CharacteristicAppEntity.$name)
        SortableBy(\CharacteristicAppEntity.$type)
        SortableBy(\CharacteristicAppEntity.$service)
        SortableBy(\CharacteristicAppEntity.$accessory)
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
private extension CharacteristicEntityQuery {
    
    @MainActor
    func entities(for identifiers: [ObjectID]) throws -> [CharacteristicAppEntity] {
        return try identifiers.compactMap { id in
            guard let characteristicModelData = try manager.managedObjectContext.fetch(CharacteristicEntity.entityName, for: id) else {
                return nil
            }
            let characteristicEntity = try CharacteristicEntity(from: characteristicModelData)
            guard let accessoryModelData = try manager.managedObjectContext.fetch(AccessoryEntity.entityName, for: ObjectID(characteristicEntity.accessory)) else {
                return nil
            }
            let accessoryEntity = try AccessoryEntity(from: accessoryModelData)
            return CharacteristicAppEntity(characteristicEntity, accessory: .init(accessoryEntity))
        }
    }
    
    func sortDescriptor(for sort: Sort<CharacteristicAppEntity>) -> FetchRequest.SortDescriptor {
        let ascending = sort.order == .ascending
        let key: CharacteristicEntity.CodingKeys
        switch sort.by {
        case \CharacteristicAppEntity.name:
            key = .name
        case \CharacteristicAppEntity.type:
            key = .type
        case \CharacteristicAppEntity.service:
            key = .service
        case \CharacteristicAppEntity.accessory:
            key = .accessory
        default:
            key = .name
        }
        return .init(property: PropertyKey(key), ascending: ascending)
    }
}

// MARK: - Supporting Types

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicEntityQuery {
    
    enum Predicate: Equatable, Hashable {
        
        case nameEqualTo(String)
        case nameContains(String)
        case characteristicTypeEqualTo(String)
        case serviceTypeEqualTo(String)
        case accessoryEqualTo(UUID)
        case formatEqualTo(CharacteristicFormatAppEnum)
        case unitEqualTo(CharacteristicUnitAppEnum?)
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicEntity.Predicate {
    
    init?(_ predicate: CharacteristicEntityQuery.Predicate) {
        switch predicate {
        case .nameEqualTo(let string):
            self = .nameEqualTo(string)
        case .nameContains(let string):
            self = .nameContains(string)
        case .characteristicTypeEqualTo(let string):
            guard let uuid = BluetoothUUID(rawValue: string) else {
                return nil
            }
            self = .characteristicTypeEqualTo(uuid)
        case .serviceTypeEqualTo(let string):
            guard let uuid = BluetoothUUID(rawValue: string) else {
                return nil
            }
            self = .serviceTypeEqualTo(uuid)
        case .accessoryEqualTo(let uuid):
            self = .accessoryEqualTo(uuid)
        case .formatEqualTo(let format):
            self = .formatEqualTo(.init(format))
        case .unitEqualTo(let unit):
            self = .unitEqualTo(unit.flatMap({ .init($0) }))
        }
    }
}
