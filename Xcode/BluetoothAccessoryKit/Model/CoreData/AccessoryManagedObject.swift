//
//  AccessoryManagedObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/30/23.
//

import Foundation
import CoreData
import Bluetooth
import BluetoothAccessory

public final class AccessoryManagedObject: NSManagedObject {
    
    internal convenience init(
        _ information: AccessoryInformation,
        context: NSManagedObjectContext
    ) {
        
        self.init(context: context)
        self.identifier = information.id
        self.update(information, context: context)
    }
    
    func update(_ value: AccessoryInformation, context: NSManagedObjectContext) {
        assert(self.identifier == value.id)
        self.name = value.name
        self.accessoryType = numericCast(value.accessory.rawValue)
        self.service = numericCast(value.service.rawValue)
        self.manufacturer = value.manufacturer
        self.serialNumber = value.serialNumber
        self.model = value.model
        self.softwareVersion = value.softwareVersion
    }
}

// MARK: - IdentifiableManagedObject

extension AccessoryManagedObject: IdentifiableManagedObject { }

// MARK: - Store

internal extension NSManagedObjectContext {
    
    @discardableResult
    func insert(_ accessories: [UUID: PairedAccessory]) throws -> [AccessoryManagedObject] {
        
        // insert accessories
        return try accessories.map { (identifier, cache) in
            if let managedObject = try find(id: identifier, type: AccessoryManagedObject.self) {
                // update read info
                managedObject.update(cache.information, context: self)
                // insert key
                try insert(cache.key, for: managedObject)
                return managedObject
            } else {
                return AccessoryManagedObject(
                    cache.information,
                    context: self
                )
            }
        }
    }
}
