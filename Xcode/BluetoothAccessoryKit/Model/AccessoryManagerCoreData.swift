//
//  AccessoryManagerCoreData.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import CoreData
import CoreModel
import CoreDataModel
import BluetoothAccessory

public enum PersistentStoreState {
    
    case uninitialized
    case loading
    case loaded
}

public extension AccessoryManager {
    
    func characteristics(
        for accessory: UUID
    ) async throws -> [CharacteristicCache] {
        try await managedObjectContext.characteristics(for: accessory)
    }
    
    func metadata(
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) throws -> CharacteristicMetadata {
        let id = CharacteristicEntity.ID(
            accessory: accessory,
            service: service,
            characteristic: characteristic
        )
        guard let modelData = try managedObjectContext.fetch(CharacteristicEntity.entityName, for: ObjectID(id)) else {
            throw BluetoothAccessoryError.metadataRequired(characteristic)
        }
        let entity = try CharacteristicEntity(from: modelData)
        return CharacteristicMetadata(entity)
    }
}

internal extension AccessoryManager {
    
    func loadPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(
            name: "BluetoothAccessoryCache",
            managedObjectModel: .init(model: .bluetoothAccessory)
        )
        let storeDescription = NSPersistentStoreDescription(url: url(for: .cacheSqlite))
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [storeDescription]
        return container
    }
    
    func loadViewContext() -> NSManagedObjectContext {
        let context = self.persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.undoManager = nil
        return context
    }
    
    func loadBackgroundContext() -> NSManagedObjectContext {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        context.undoManager = nil
        return context
    }
    
    func updateCoreDataCache() async throws {
        let cache = self.cache
        try await self.commit { context in
            for (id, cache) in cache {
                var accessory: AccessoryEntity
                if let accessoryData = try context.fetch(AccessoryEntity.entityName, for: ObjectID(id)) {
                    accessory = try AccessoryEntity(from: accessoryData)
                    accessory.update(cache.information)
                } else {
                    accessory = AccessoryEntity(cache.information, keys: [cache.key.id])
                }
                let key = KeyEntity(cache.key, accessory: id)
                // save
                var modelData = [ModelData]()
                try modelData.append(accessory.encode())
                try modelData.append(key.encode())
                try context.insert(modelData)
            }
        }
    }
    
    func loadPersistentStores() async {
        guard persistentStoreState == .uninitialized else {
            return
        }
        persistentStoreState = .loading
        do {
            for try await store in persistentContainer.loadPersistentStores() {
                log("Loaded CoreData store \(store.url?.absoluteString ?? "")")
            }
            persistentStoreState = .loaded
        }
        catch {
            persistentStoreState = .uninitialized
            log("Error loading CoreData: \(error.localizedDescription)")
            // remove sqlite file at url
            for url in persistentContainer.persistentStoreDescriptions.compactMap({ $0.url }) {
                try? fileManager.removeItem(at: url)
            }
            // try again
            await loadPersistentStores()
        }
    }
    
    func commit(_ block: @escaping (NSManagedObjectContext) throws -> ()) async throws {
        // load persist store
        await loadPersistentStores()
        // modify background context
        let context = self.backgroundContext
        assert(context.concurrencyType == .privateQueueConcurrencyType)
        try await context.perform { [unowned context, unowned self] in
            context.reset()
            // run closure
            do {
                try block(context)
            }
            catch {
                if context.hasChanges {
                    context.undo()
                }
                throw error
            }
            // attempt to save
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                self.log("⚠️ Unable to commit changes: \(error.localizedDescription)")
                assertionFailure("Core Data error. \(error)")
                throw error
            }
        }
        // update SwiftUI that doesnt use FRC
        self.objectWillChange.send()
    }
    
    func cacheCoreDataAccessory(
        _ information: AccessoryInformation
    ) async throws {
        try await commit { context in
            if var modelData = try context.fetch(AccessoryEntity.entityName, for: ObjectID(information.id)) {
                var entity = try AccessoryEntity(from: modelData)
                entity.update(information)
                modelData = try entity.encode()
                try context.insert(modelData)
            } else {
                let modelData = try AccessoryEntity(information).encode()
                try context.insert(modelData)
            }
        }
    }
    
    func updateCoreDataCharacteristics(
        _ characteristics: [(service: BluetoothUUID, metadata: CharacteristicMetadata)],
        for accessory: UUID
    ) async throws {
        try await commit { context in
            guard let _ = try context.fetch(AccessoryEntity.entityName, for: ObjectID(accessory)) else {
                assertionFailure()
                return
            }
            let values = try characteristics.map { (service, metadata) in
                let id = CharacteristicCache.ID(
                    accessory: accessory,
                    service: service,
                    characteristic: metadata.type
                )
                var entity: CharacteristicEntity
                if var modelData = try context.fetch(CharacteristicEntity.entityName, for: ObjectID(id)) {
                    entity = try CharacteristicEntity(from: modelData)
                    entity.update(metadata: metadata)
                } else {
                    entity = .init(metadata: metadata, accessory: accessory, service: service)
                }
                return try entity.encode()
            }
            try context.insert(values)
        }
    }
    
    func updateCoreDataCharacteristicValue(
        _ newValue: CharacteristicCache.Value,
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) async throws {
        let id = CharacteristicEntity.ID(
            accessory: accessory,
            service: service,
            characteristic: characteristic
        )
        try await commit { context in
            guard var modelData = try context.fetch(CharacteristicEntity.entityName, for: ObjectID(id)) else {
                throw BluetoothAccessoryError.metadataRequired(characteristic)
            }
            var entity = try CharacteristicEntity(from: modelData)
            let oldValues = entity.values
            var values: [CharacteristicValueEntity]
            // set new value
            switch newValue {
            case .single(let value):
                values = [.init(characteristic: id, index: 0, value: value)]
            case .list(let array):
                values = array
                    .enumerated()
                    .map { CharacteristicValueEntity(characteristic: id, index: UInt($0.offset), value: $0.element) }
            }
            entity.values = values.map { $0.id }
            // remove old values
            try oldValues
                .filter { entity.values.contains($0) == false }
                .forEach { try context.delete(CharacteristicValueEntity.entityName, for: .init($0)) }
            // save new values
            modelData = try entity.encode()
            var insertedValues = [ModelData]()
            insertedValues.append(modelData)
            insertedValues += try values.map { try $0.encode() }
            try context.insert(insertedValues)
        }
    }
    
    func addCoreDataCharacteristicListValue(
        _ newValue: CharacteristicValue,
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) async throws {
        let id = CharacteristicEntity.ID(
            accessory: accessory,
            service: service,
            characteristic: characteristic
        )
        try await commit { context in
            guard let modelData = try context.fetch(CharacteristicEntity.entityName, for: ObjectID(id)) else {
                throw BluetoothAccessoryError.metadataRequired(characteristic)
            }
            var entity = try CharacteristicEntity(from: modelData)
            // set new value
            assert(entity.isList)
            let index = entity.values.last?.index ?? 0
            let valueEntity = CharacteristicValueEntity(
                characteristic: id,
                index: index,
                value: newValue
            )
            entity.values.append(valueEntity.id)
            // save new values
            var insertedValues = [ModelData]()
            try insertedValues.append(entity.encode())
            try insertedValues.append(valueEntity.encode())
            try context.insert(insertedValues)
        }
    }
}
