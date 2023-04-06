//
//  CharacteristicManagedObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/30/23.
//

import Foundation
import CoreData
import Bluetooth
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
        self.lastUpdate = Date()
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
    
    var properties: BitMaskOptionSet<BluetoothAccessory.CharacteristicProperty> {
        var properties = BitMaskOptionSet<BluetoothAccessory.CharacteristicProperty>()
        if isReadable {
            properties.insert(.read)
        }
        if isWritable {
            properties.insert(.write)
        }
        if isWriteWithoutResponse {
            properties.insert(.writeWithoutResponse)
        }
        if isEncrypted {
            properties.insert(.encrypted)
        }
        if isList {
            properties.insert(.list)
        }
        return properties
    }
}

internal extension CharacteristicCache {
    
    init(managedObject: CharacteristicManagedObject) {
        let metadata = CharacteristicMetadata(managedObject: managedObject)
        let value: Value?
        if metadata.properties.contains(.list) {
            if let array = managedObject.values?.array as? [CharacteristicValueManagedObject] {
                value = .list(array.map { CharacteristicValue(managedObject: $0) })
            } else {
                value = nil
            }
        } else {
            value = managedObject.value.flatMap { .single(.init(managedObject: $0)) }
        }
        self.init(
            accessory: managedObject.accessory!.identifier!,
            service: .init(rawValue: managedObject.service!)!,
            metadata: .init(managedObject: managedObject),
            value: value,
            updated: managedObject.lastUpdate!
        )
    }
}

internal extension CharacteristicMetadata {
    
    init(managedObject: CharacteristicManagedObject) {
        self.init(
            type: BluetoothUUID(rawValue: managedObject.type!)!,
            name: managedObject.name ?? "",
            properties: managedObject.properties,
            format: .init(rawValue: UInt8(managedObject.format))!,
            unit: managedObject.unit.flatMap { .init(rawValue: $0.uint8Value) }
        )
    }
}

internal extension NSManagedObjectContext {
    
    func metadata(
        for characteristic: BluetoothUUID,
        service: BluetoothUUID,
        accessory: UUID
    ) throws -> CharacteristicMetadata {
        let id = CharacteristicCache.id(accessory: accessory, service: service, characteristic: characteristic)
        guard let managedObject = try self.find(
            identifier: id as NSString,
            propertyName: #keyPath(CharacteristicManagedObject.identifier),
            type: CharacteristicManagedObject.self
        ) else {
            throw BluetoothAccessoryError.metadataRequired(characteristic)
        }
        assert(managedObject.type == characteristic.rawValue)
        assert(managedObject.service == service.rawValue)
        assert(managedObject.accessory?.identifier == accessory)
        return CharacteristicMetadata(managedObject: managedObject)
    }
}
