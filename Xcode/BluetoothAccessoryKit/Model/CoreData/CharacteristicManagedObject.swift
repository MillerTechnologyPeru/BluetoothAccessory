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
        self.accessory = accessory
        self.service = value.service.rawValue
        self.update(value)
    }
}

internal extension CharacteristicManagedObject {
    
    func update(_ value: CharacteristicCache) {
        assert(accessory?.identifier == value.accessory)
        assert(service == value.service.rawValue)
        self.lastUpdate = Date()
        update(value.metadata)
    }
    
    func update(_ metadata: CharacteristicMetadata) {
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
}
