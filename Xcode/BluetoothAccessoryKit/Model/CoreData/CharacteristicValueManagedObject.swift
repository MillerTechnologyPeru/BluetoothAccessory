//
//  CharacteristicValueObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/31/23.
//

import Foundation
import CoreData
import BluetoothAccessory
import TLVCoding

public final class CharacteristicValueManagedObject: NSManagedObject {
    
    internal convenience init(
        _ value: CharacteristicValue,
        characteristic: CharacteristicManagedObject,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.characteristic = characteristic
        self.encoded = value.encode()
        switch value {
        case .tlv8(let data):
            self.binaryValue = data
        case .string(let string):
            self.stringValue = string
        case .data(let data):
            self.binaryValue = data
        case .date(let date):
            self.dateValue = date
        case .uuid(let uuid):
            self.uuidValue = uuid
        case .bool(let bool):
            self.boolValue = bool
        case .int8(let value):
            self.intValue = numericCast(value)
        case .int16(let value):
            self.intValue = numericCast(value)
        case .int32(let value):
            self.intValue = numericCast(value)
        case .uint8(let value):
            self.intValue = numericCast(value)
        case .uint16(let value):
            self.intValue = numericCast(value)
        case .uint32(let value):
            self.intValue = numericCast(value)
        case .uint64(let value):
            self.intValue = .init(bitPattern: value)
        case .int64(let value):
            self.intValue = value
        case .float(let float):
            self.floatValue = float
        case .double(let double):
            self.doubleValue = double
        }
    }
}

public extension CharacteristicValue {
    
    init(managedObject: CharacteristicValueManagedObject) {
        let format = CharacteristicFormat(rawValue: UInt8(managedObject.characteristic!.format))!
        self = CharacteristicValue.init(from: managedObject.encoded!, format: format)!
    }
}
