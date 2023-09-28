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
        matching predicates: [CharacteristicEntityQueryPredicate],
        mode: ComparatorMode,
        sortedBy sortDescriptors: [Sort<CharacteristicAppEntity>],
        limit: Int?
    ) throws -> [CharacteristicAppEntity] {
        guard predicates.isEmpty == false else {
            return []
        }
        var subpredicates = [FetchRequest.Predicate]()
        subpredicates.reserveCapacity(predicates.count)
        var accessoryPredicate = false
        for predicate in predicates {
            guard let comparison = FetchRequest.Predicate.Comparison(predicate) else {
                return [] // invalid query
            }
            // check if filtering by accessory
            switch predicate {
            case .accessoryEqualTo:
                accessoryPredicate = true
            default:
                break
            }
            subpredicates.append(.comparison(comparison))
        }
        guard accessoryPredicate else {
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
    
    static var properties = EntityQueryProperties<CharacteristicAppEntity, CharacteristicEntityQueryPredicate> {
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
            EqualToComparator { .formatEqualTo(.init($0)) }
        }
        Property(\CharacteristicAppEntity.$unit) {
            EqualToComparator { .unitEqualTo($0.flatMap { .init($0) }) }
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

enum CharacteristicEntityQueryPredicate {
    
    case nameEqualTo(String)
    case nameContains(String)
    
    case characteristicTypeEqualTo(String)
    case serviceTypeEqualTo(String)
    case accessoryEqualTo(UUID)
    
    case formatEqualTo(CharacteristicFormat)
    case unitEqualTo(CharacteristicUnit?)
}

extension FetchRequest.Predicate.Comparison {
    
    init?(_ predicate: CharacteristicEntityQueryPredicate) {
        switch predicate {
        case .nameEqualTo(let string):
            self.init(
                left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.name.rawValue)),
                right: .attribute(.string(string)),
                type: .equalTo,
                options: [.caseInsensitive, .localeSensitive, .diacriticInsensitive]
            )
        case .nameContains(let string):
            self.init(
                left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.name.rawValue)),
                right: .attribute(.string(string)),
                type: .contains,
                options: [.caseInsensitive, .localeSensitive, .diacriticInsensitive]
            )
        case .characteristicTypeEqualTo(let string):
            guard let uuid = UUID(uuidString: string) else {
                return nil
            }
            self.init(
                left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.type.rawValue)),
                right: .attribute(.uuid(uuid)),
                type: .equalTo
            )
        case .serviceTypeEqualTo(let string):
            guard let uuid = UUID(uuidString: string) else {
                return nil
            }
            self.init(
                left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.service.rawValue)),
                right: .attribute(.uuid(uuid)),
                type: .equalTo
            )
        case .accessoryEqualTo(let uuid):
            self.init(
                left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.accessory.rawValue)),
                right: .relationship(.toOne(ObjectID(uuid))),
                type: .equalTo
            )
        case .formatEqualTo(let format):
            self.init(
                left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.format.rawValue)),
                right: .attribute(.int16(numericCast(format.rawValue))),
                type: .equalTo
            )
        case .unitEqualTo(let unit):
            self.init(
                left: .keyPath(.init(rawValue: CharacteristicEntity.CodingKeys.unit.rawValue)),
                right: unit.flatMap { .attribute(.int16(numericCast($0.rawValue))) } ?? .attribute(.null),
                type: .equalTo
            )
        }
    }
}
