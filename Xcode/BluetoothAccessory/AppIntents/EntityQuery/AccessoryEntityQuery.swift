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
