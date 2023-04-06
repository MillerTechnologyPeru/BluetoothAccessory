//
//  ManagedObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import CoreData
import Predicate

public extension NSManagedObjectModel {
    
    static var bluetoothAccessory: NSManagedObjectModel {
        guard let url = Bundle(for: AccessoryManager.self).url(forResource: "Model", withExtension: "momd")
            else { fatalError("No url for model") }
        guard let model = NSManagedObjectModel(contentsOf: url)
            else { fatalError("No model at \(url.path)") }
        return model
    }
}

internal extension NSManagedObjectContext {
    
    func find<T>(identifier: NSObject, propertyName: String, type: T.Type) throws -> T? where T: NSManagedObject {
        
        let fetchRequest = NSFetchRequest<T>()
        fetchRequest.entity = T.entity()
        if let uuid = identifier as? NSUUID {
            let predicate = (.keyPath(.init(rawValue: propertyName)) == .value(.uuid(uuid as UUID))).toFoundation()
            fetchRequest.predicate = predicate
            assert(predicate == NSPredicate(format: "%K == %@", propertyName, identifier))
        } else {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", propertyName, identifier)
        }
        fetchRequest.fetchLimit = 1
        fetchRequest.includesSubentities = true
        fetchRequest.returnsObjectsAsFaults = false
        return try self.fetch(fetchRequest).first
    }
}

public protocol IdentifiableManagedObject {
    
    var identifier: UUID? { get }
}

public extension NSManagedObjectContext {
    
    func find<T>(id: UUID, type: T.Type) throws -> T? where T: IdentifiableManagedObject, T: NSManagedObject {
        
        let fetchRequest = NSFetchRequest<T>()
        fetchRequest.entity = T.entity()
        let predicate = ("identifier" == id).toFoundation()
        fetchRequest.predicate = predicate
        assert(predicate == NSPredicate(format: "%K == %@", "identifier", id as NSUUID))
        fetchRequest.fetchLimit = 1
        fetchRequest.includesSubentities = true
        fetchRequest.returnsObjectsAsFaults = false
        return try self.fetch(fetchRequest).first
    }
}
