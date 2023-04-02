//
//  CharacteristicManagedObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/30/23.
//

import Foundation
import CoreData
import BluetoothAccessory

public final class CharacteristicManagedObject: NSManagedObject {
    
    internal convenience init(
        _ value: CharacteristicCache,
        accessory: AccessoryManagedObject,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        assert(accessory.identifier == value.accessory)
        self.identifier = value.id
        self.accessory = accessory
        self.service = value.service.rawValue
        self.update(value, context: context)
    }
}

internal extension CharacteristicManagedObject {
    
    func update(_ cache: CharacteristicCache, context: NSManagedObjectContext) {
        assert(accessory?.identifier == cache.accessory)
        assert(service == cache.service.rawValue)
        self.lastUpdate = Date()
        update(cache.metadata, context: context)
        update(cache.value, context: context)
    }
    
    func update(_ metadata: CharacteristicMetadata, context: NSManagedObjectContext) {
        self.type = metadata.type.rawValue
        self.name = metadata.name
        self.format = numericCast(metadata.format.rawValue)
        self.unit = metadata.unit.flatMap { NSNumber(value: $0.rawValue) }
        self.isReadable = metadata.properties.contains(.read)
        self.isWritable = metadata.properties.contains(.write)
        self.isWriteWithoutResponse = metadata.properties.contains(.writeWithoutResponse)
        self.isEncrypted = metadata.properties.contains(.encrypted)
        self.isList = metadata.properties.contains(.list)
    }
    
    func update(_ value: CharacteristicCache.Value?, context: NSManagedObjectContext) {
        self.value.flatMap { context.delete($0) }
        self.values?.forEach { context.delete($0 as! NSManagedObject) }
        switch value {
        case .none:
            self.values = nil
            self.value = nil
        case let .single(value):
            self.values = nil
            self.value = CharacteristicValueManagedObject(value, characteristic: self, context: context)
        case let .list(values):
            self.value = nil
            self.values = NSOrderedSet(array: values.map { CharacteristicValueManagedObject($0, characteristic: self, context: context) })
        }
    }
}
