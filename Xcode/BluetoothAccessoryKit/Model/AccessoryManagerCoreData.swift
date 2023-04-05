//
//  AccessoryManagerCoreData.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import CoreData
import BluetoothAccessory

public extension AccessoryManager {
    
    
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
        context.automaticallyMergesChangesFromParent = true
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
    
    func updateCoreDataCache() async {
        let cache = self.cache
        await self.backgroundContext.commit { context in
            try context.insert(cache)
        }
    }
    
    func updateCoreDataCharacteristics(
        _ characteristics: [(service: BluetoothUUID, metadata: CharacteristicMetadata)],
        for accessory: UUID
    ) async {
        await self.backgroundContext.commit { context in
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
                managedObjects.contains(where: { $0 === managedOject }) == false
            }
            .forEach {
                context.delete($0)
            }
            // set new value
            accessoryManagedObject.characteristics = NSOrderedSet(array: managedObjects)
        }
    }
    
    func metadata(
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) async throws -> CharacteristicMetadata {
        let id = CharacteristicCache.id(accessory: accessory, service: service, characteristic: characteristic)
        let context = self.backgroundContext
        return try await context.perform {
            guard let managedObject = try context.find(
                identifier: id as NSString,
                propertyName: #keyPath(CharacteristicManagedObject.identifier),
                type: CharacteristicManagedObject.self
            ) else {
                throw BluetoothAccessoryError.metadataRequired(characteristic)
            }
            return CharacteristicMetadata(managedObject: managedObject)
        }
    }
}
