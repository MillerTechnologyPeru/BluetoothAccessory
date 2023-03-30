//
//  NewKeyManagedObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/30/23.
//

import Foundation
import CoreData
import BluetoothAccessory

public final class NewKeyManagedObject: NSManagedObject {
    
    internal convenience init(_ value: NewKey, accessory: AccessoryManagedObject, context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = value.id
        self.update(value, accessory: accessory, context: context)
    }
    
    internal func update(_ value: NewKey, accessory: AccessoryManagedObject, context: NSManagedObjectContext) {
        self.accessory = accessory
        self.name = value.name
        self.created = value.created
        self.expiration = value.expiration
        self.permission = numericCast(value.permission.type.rawValue)
        if case let .scheduled(schedule) = value.permission {
            if let _ = self.schedule {
                // don't update
            } else {
                self.schedule = ScheduleManagedObject(schedule, context: context)
            }
        }
    }
}

public extension NewKey {
    
    init?(managedObject: NewKeyManagedObject) {
        
        guard let id = managedObject.identifier,
            let name = managedObject.name,
            let created = managedObject.created,
            let permissionType = PermissionType(rawValue: numericCast(managedObject.permission)),
            let expiration = managedObject.expiration
            else { return nil }
        
        let permission: Permission
        switch permissionType {
        case .owner:
            permission = .owner
        case .admin:
            permission = .admin
        case .anytime:
            permission = .anytime
        case .scheduled:
            guard let schedule = managedObject.schedule.flatMap({ Permission.Schedule(managedObject: $0) })
                else { return nil }
            permission = .scheduled(schedule)
        }
        
        self.init(
            id: id,
            name: name,
            permission: permission,
            created: created,
            expiration: expiration
        )
    }
}

// MARK: - IdentifiableManagedObject

extension NewKeyManagedObject: IdentifiableManagedObject { }

// MARK: - Store

internal extension NSManagedObjectContext {
    
    @discardableResult
    func insert(_ newKey: NewKey, for accessory: AccessoryManagedObject) throws -> NewKeyManagedObject {
        
        if let managedObject = try find(id: newKey.id, type: NewKeyManagedObject.self) {
            assert(managedObject.accessory == accessory, "Key stored with conflicting lock")
            managedObject.update(newKey, accessory: accessory, context: self)
            return managedObject
        } else {
            return NewKeyManagedObject(newKey, accessory: accessory, context: self)
        }
    }
}
