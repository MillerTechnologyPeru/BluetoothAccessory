//
//  AccessoryService.swift
//  
//
//  Created by Alsey Coleman Miller on 3/22/23.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Service
public protocol AccessoryService {
    
    static var type: BluetoothUUID { get }
    
    var serviceHandle: UInt16 { get }
    
    var characteristics: [AnyManagedCharacteristic] { get }
    
    mutating func update(characteristic: UInt16, with newValue: ManagedCharacteristicValue) -> Bool
}

public extension AccessoryService {
    
    mutating func update(characteristic: UInt16, with newValue: ManagedCharacteristicValue) -> Bool { false }
}

public struct AnyManagedCharacteristic: Equatable, Hashable {
    
    public let uuid: BluetoothUUID
    
    public let handle: UInt16
        
    public let value: ManagedCharacteristicValue
    
    public let format: CharacteristicFormat
    
    public let properties: BitMaskOptionSet<CharacteristicProperty>
    
    internal init(
        uuid: BluetoothUUID,
        handle: UInt16,
        value: ManagedCharacteristicValue,
        format: CharacteristicFormat,
        properties: BitMaskOptionSet<CharacteristicProperty>
    ) {
        self.uuid = uuid
        self.handle = handle
        self.value = value
        self.format = format
        self.properties = properties
    }
}

public enum ManagedCharacteristicValue: Equatable, Hashable {
    
    case none
    case single(CharacteristicValue)
    case list([CharacteristicValue])
}

@propertyWrapper
public struct ManagedCharacteristic <Characteristic: AccessoryCharacteristic> {
        
    public let valueHandle: UInt16
    
    public init(
        wrappedValue: Characteristic.Value,
        valueHandle: UInt16
    ) {
        assert(Characteristic.properties.contains(.list) == false)
        self.wrappedValue = wrappedValue
        self.valueHandle = valueHandle
    }
    
    public var wrappedValue: Characteristic.Value

    public var projectedValue: AnyManagedCharacteristic {
        .init(
            uuid: Characteristic.type,
            handle: valueHandle,
            value: .single(wrappedValue.characteristicValue),
            format: Characteristic.Value.characteristicFormat,
            properties: Characteristic.properties
        )
    }
}

@propertyWrapper
public struct ManagedWriteOnlyCharacteristic <Characteristic: AccessoryCharacteristic> {
        
    public let valueHandle: UInt16
    
    public init(
        valueHandle: UInt16
    ) {
        assert(Characteristic.properties.contains(.list) == false)
        assert(Characteristic.properties.contains(.read) == false)
        assert(Characteristic.properties.contains(.write))
        self.valueHandle = valueHandle
    }
    
    public var wrappedValue: Characteristic.Value?
    
    public var projectedValue: AnyManagedCharacteristic {
        .init(
            uuid: Characteristic.type,
            handle: valueHandle,
            value: wrappedValue.flatMap { .single($0.characteristicValue) } ?? .none,
            format: Characteristic.Value.characteristicFormat,
            properties: Characteristic.properties
        )
    }
}

@propertyWrapper
public struct ManagedListCharacteristic <Characteristic: AccessoryCharacteristic> {
        
    public let valueHandle: UInt16
    
    public init(
        wrappedValue: [Characteristic.Value] = [],
        valueHandle: UInt16
    ) {
        assert(Characteristic.properties.contains(.list))
        self.wrappedValue = wrappedValue
        self.valueHandle = valueHandle
    }
    
    public var wrappedValue: [Characteristic.Value]
    
    public var projectedValue: AnyManagedCharacteristic {
        .init(
            uuid: Characteristic.type,
            handle: valueHandle,
            value: .list(wrappedValue.map { $0.characteristicValue }),
            format: Characteristic.Value.characteristicFormat,
            properties: Characteristic.properties
        )
    }
}
