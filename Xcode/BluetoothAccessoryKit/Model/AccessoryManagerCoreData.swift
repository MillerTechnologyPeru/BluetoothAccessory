//
//  AccessoryManagerCoreData.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import CoreData

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
    
    
}
