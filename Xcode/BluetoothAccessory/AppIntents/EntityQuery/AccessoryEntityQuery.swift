//
//  AccessoryEntityQuery.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit

// MARK: - EntityQuery

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct AccessoryEntityQuery: EntityQuery {
    
    let manager: AccessoryManager
    
    init(manager: AccessoryManager) {
        self.manager = manager
    }
    
    init() {
        self.init(manager: BluetoothAccessoryApp.accessoryManager)
    }
    
    func entities(for identifiers: [AccessoryAppEntity.ID]) async throws -> [AccessoryAppEntity] {
        let cache = await manager.cache
        return identifiers.compactMap { cache[$0].flatMap({ .init($0.information) }) }
    }
    
    func suggestedEntities() async throws -> [AccessoryAppEntity] {
        let cache = await manager.cache
        return cache.values
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .map { .init($0.information) }
    }
}

// MARK: - EntityStringQuery

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryEntityQuery: EntityStringQuery {
    
    func entities(matching query: String) async throws -> [AccessoryAppEntity] {
        let accessories = await manager.cache.values
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .map { $0.information }
            .filter {
                $0.name.localizedCaseInsensitiveContains(query)
                || $0.type.description.localizedCaseInsensitiveContains(query)
                || $0.service.description.localizedCaseInsensitiveContains(query)
                || $0.manufacturer.description.localizedCaseInsensitiveContains(query)
                || $0.model.description.localizedCaseInsensitiveContains(query)
                || $0.serialNumber.description.localizedCaseInsensitiveContains(query)
            }
        return accessories.map { .init($0) }
    }
}

// MARK: - EnumerableEntityQuery

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryEntityQuery: EnumerableEntityQuery {
    
    func allEntities() async throws -> [AccessoryAppEntity] {
        let cache = await manager.cache
        return cache.values
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .map { .init($0.information) }
    }
}

// MARK: - EntityPropertyQuery

/*
@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryEntityQuery: EntityPropertyQuery {
    
    func entities(
        matching predicates: [AccessoryEntityQueryPredicate],
        mode: ComparatorMode,
        sortedBy sortDescriptors: [Sort<AccessoryAppEntity>],
        limit: Int?
    ) async throws -> [AccessoryAppEntity] {
        []
    }
    
    static var properties = EntityQueryProperties<AccessoryAppEntity, AccessoryEntityQueryPredicate> {
        Property(\AccessoryAppEntity.$name) {
            EqualToComparator { .nameEqualTo($0) }
            ContainsComparator { .nameContains($0) }
        }
        Property(\AccessoryAppEntity.$serialNumber) {
            EqualToComparator { .serialNumberEqualTo($0) }
        }
        Property(\AccessoryAppEntity.$type) {
            EqualToComparator { .accessoryTypeEqualTo(.init($0)) }
        }
        Property(\AccessoryAppEntity.$service) {
            EqualToComparator { .serviceTypeEqualTo(.init($0)) }
        }
        Property(\AccessoryAppEntity.$manufacturer) {
            EqualToComparator { .manufacturerEqualTo($0) }
            ContainsComparator { .manufacturerContains($0) }
        }
        Property(\AccessoryAppEntity.$model) {
            EqualToComparator { .modelEqualTo($0) }
            ContainsComparator { .modelContains($0) }
        }
        Property(\AccessoryAppEntity.$softwareVersion) {
            EqualToComparator { .softwareVersionEqualTo($0) }
        }
    }
    
    static var sortingOptions = SortingOptions {
        SortableBy(\AccessoryAppEntity.$name)
        SortableBy(\AccessoryAppEntity.$serialNumber)
        SortableBy(\AccessoryAppEntity.$type)
        SortableBy(\AccessoryAppEntity.$service)
        SortableBy(\AccessoryAppEntity.$manufacturer)
        SortableBy(\AccessoryAppEntity.$model)
        SortableBy(\AccessoryAppEntity.$softwareVersion)
    }
}
*/
// MARK: - Supporting Types

enum AccessoryEntityQueryPredicate {
    
    case nameEqualTo(String)
    case nameContains(String)
    
    case serialNumberEqualTo(String)
    
    case accessoryTypeEqualTo(AccessoryType)
    
    case serviceTypeEqualTo(ServiceType)
    
    case manufacturerEqualTo(String)
    case manufacturerContains(String)
    
    case modelEqualTo(String)
    case modelContains(String)
    
    case softwareVersionEqualTo(String)
    
    func filter(_ value: AccessoryInformation) -> Bool {
        switch self {
        case .nameEqualTo(let string):
            return value.name.lowercased() == string.lowercased()
        case .nameContains(let string):
            return value.name.localizedCaseInsensitiveContains(string)
        case .serialNumberEqualTo(let string):
            return value.serialNumber.lowercased() == string.lowercased()
        case .accessoryTypeEqualTo(let accessoryType):
            return value.type == accessoryType
        case .serviceTypeEqualTo(let serviceType):
            return value.service == serviceType
        case .manufacturerEqualTo(let string):
            return value.manufacturer.lowercased() == string.lowercased()
        case .manufacturerContains(let string):
            return value.manufacturer.localizedCaseInsensitiveContains(string)
        case .modelEqualTo(let string):
            return value.model.lowercased() == string.lowercased()
        case .modelContains(let string):
            return value.model.localizedCaseInsensitiveContains(string)
        case .softwareVersionEqualTo(let string):
            return value.softwareVersion.lowercased() == string.lowercased()
        }
    }
}
