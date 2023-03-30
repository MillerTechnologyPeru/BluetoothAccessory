//
//  KeyManagedObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/30/23.
//

import Foundation
import CoreData
import BluetoothAccessory

public final class KeyManagedObject: NSManagedObject {
    
    internal convenience init(_ value: Key, accessory: AccessoryManagedObject, context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = value.id
        self.update(value, accessory: accessory, context: context)
    }
    
    internal func update(_ value: Key, accessory: AccessoryManagedObject, context: NSManagedObjectContext) {
        self.accessory = accessory
        self.name = value.name
        self.created = value.created
        self.permission = numericCast(value.permission.type.rawValue)
        if case let .scheduled(schedule) = value.permission {
            if let _ = self.schedule {
                // don't update
            } else {
                self.schedule = .init(schedule, context: context)
            }
        }
    }
}

public extension Key {
    
    init?(managedObject: KeyManagedObject) {
        
        guard let id = managedObject.identifier,
            let name = managedObject.name,
            let created = managedObject.created,
            let permissionType = PermissionType(rawValue: numericCast(managedObject.permission))
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
            created: created,
            permission: permission
        )
    }
}

// MARK: - IdentifiableManagedObject

extension KeyManagedObject: IdentifiableManagedObject { }

// MARK: - Store

internal extension NSManagedObjectContext {
    
    @discardableResult
    func insert(_ key: Key, for accessory: AccessoryManagedObject) throws -> KeyManagedObject {
        
        if let managedObject = try find(id: key.id, type: KeyManagedObject.self) {
            assert(managedObject.accessory == accessory, "Key stored with conflicting lock")
            managedObject.update(key, accessory: accessory, context: self)
            return managedObject
        } else {
            return KeyManagedObject(key, accessory: accessory, context: self)
        }
    }
    
    @discardableResult
    func insert(
        _ key: KeysCharacteristic.Item,
        for accessory: AccessoryManagedObject
    ) throws -> NSManagedObject {
        switch key {
        case let .key(key):
            return try insert(key, for: accessory)
        case let .newKey(key):
            return try insert(key, for: accessory)
        }
    }
}
