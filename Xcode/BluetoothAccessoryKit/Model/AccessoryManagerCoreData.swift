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
        #if os(tvOS)
        guard let containerURL = fileManager.cachesDirectory
            else { fatalError("Couldn't get caches directory") }
        #else
        guard let containerURL = fileManager.containerURL(for: configuration.appGroup)
            else { fatalError("Couldn't get app group") }
        #endif
        let container = NSPersistentContainer(name: "BluetoothAccessoryCache", managedObjectModel: .bluetoothAccessory)
        let storeDescription = NSPersistentStoreDescription(url: containerURL.appendingPathComponent("data.sqlite"))
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
