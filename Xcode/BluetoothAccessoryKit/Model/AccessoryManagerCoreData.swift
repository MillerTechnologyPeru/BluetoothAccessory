//
//  AccessoryManagerCoreData.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import CoreData
import BluetoothAccessory
public enum PersistentStoreState {
    
    case uninitialized
    case loading
    case loaded
}

public extension AccessoryManager {
    
    func characteristics(
        for accessory: UUID
    ) throws -> [CharacteristicCache] {
        try managedObjectContext.characteristics(for: accessory)
    }
    
    func metadata(
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) throws -> CharacteristicMetadata {
        return try managedObjectContext.metadata(
            for: characteristic,
            service: service,
            accessory: accessory
        )
    }
}

internal extension AccessoryManager {
    
    func loadPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(
            name: "BluetoothAccessoryCache",
            managedObjectModel: .bluetoothAccessory
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
            try context.insert(cache)
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
            if let managedObject = try context.find(id: information.id, type: AccessoryManagedObject.self) {
                managedObject.update(information, context: context)
            } else {
                let _ = AccessoryManagedObject(information, context: context)
            }
        }
    }
    
    func updateCoreDataCharacteristics(
        _ characteristics: [(service: BluetoothUUID, metadata: CharacteristicMetadata)],
        for accessory: UUID
    ) async throws {
        try await commit { context in
            guard let accessoryManagedObject = try context.find(id: accessory, type: AccessoryManagedObject.self) else {
                assertionFailure()
                return
            }
            let oldValues = (accessoryManagedObject.characteristics?.array ?? [])
                .map { $0 as! CharacteristicManagedObject }
            var managedObjects = [CharacteristicManagedObject]()
            managedObjects.reserveCapacity(characteristics.count)
            for (service, metadata) in characteristics {
                let id = CharacteristicCache.id(
                    accessory: accessory,
                    service: service,
                    characteristic: metadata.type
                )
                // find or create
                let managedObject: CharacteristicManagedObject
                if let object = try context.find(
                    identifier: id as NSString,
                    propertyName: #keyPath(CharacteristicManagedObject.identifier),
                    type: CharacteristicManagedObject.self
                ) {
                    managedObject = object
                    managedObject.update(metadata, context: context)
                } else {
                    let cache = CharacteristicCache(
                        accessory: accessory,
                        service: service,
                        metadata: metadata,
                        updated: Date()
                    )
                    managedObject = CharacteristicManagedObject(cache, accessory: accessoryManagedObject, context: context)
                }
                assert(managedObject.identifier == id)
                assert(managedObject.service == service.rawValue)
                assert(managedObject.accessory?.identifier == accessory)
                managedObjects.append(managedObject)
            }
            // remove old characteristics
            oldValues
            .filter { managedOject in
                managedObjects.contains(where: { $0.identifier == managedOject.identifier }) == false
            }
            .forEach {
                context.delete($0)
            }
            // set new value
            accessoryManagedObject.characteristics = NSOrderedSet(array: managedObjects)
        }
    }
    
    func updateCoreDataCharacteristicValue(
        _ newValue: CharacteristicCache.Value,
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) async throws {
        let id = CharacteristicCache.id(accessory: accessory, service: service, characteristic: characteristic)
        return try await commit { context in
            guard let managedObject = try context.find(
                identifier: id as NSString,
                propertyName: #keyPath(CharacteristicManagedObject.identifier),
                type: CharacteristicManagedObject.self
            ) else {
                throw BluetoothAccessoryError.metadataRequired(characteristic)
            }
            assert(managedObject.type == characteristic.rawValue)
            assert(managedObject.service == service.rawValue)
            assert(managedObject.accessory?.identifier == accessory)
            // delete old value
            managedObject.value
                .flatMap { context.delete($0) }
            managedObject.values?
                .forEach { context.delete($0 as! NSManagedObject) }
            // set new value
            switch newValue {
            case .single(let characteristicValue):
                assert(managedObject.isList == false)
                managedObject.value = CharacteristicValueManagedObject(
                    characteristicValue,
                    characteristic: managedObject,
                    context: context
                )
            case .list(let array):
                assert(managedObject.isList)
                managedObject.values = NSOrderedSet(array: array.map {
                    CharacteristicValueManagedObject(
                        $0,
                        characteristic: managedObject,
                        context: context
                    )
                })
            }
        }
    }
    
    func addCoreDataCharacteristicListValue(
        _ newValue: CharacteristicValue,
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) async throws {
        let id = CharacteristicCache.id(accessory: accessory, service: service, characteristic: characteristic)
        return try await commit { context in
            guard let managedObject = try context.find(
                identifier: id as NSString,
                propertyName: #keyPath(CharacteristicManagedObject.identifier),
                type: CharacteristicManagedObject.self
            ) else {
                throw BluetoothAccessoryError.metadataRequired(characteristic)
            }
            assert(managedObject.type == characteristic.rawValue)
            assert(managedObject.service == service.rawValue)
            assert(managedObject.accessory?.identifier == accessory)
            // set new value
            assert(managedObject.isList)
            let valueObject = CharacteristicValueManagedObject(
                newValue,
                characteristic: managedObject,
                context: context
            )
            managedObject.addToValues(valueObject)
        }
    }
}
