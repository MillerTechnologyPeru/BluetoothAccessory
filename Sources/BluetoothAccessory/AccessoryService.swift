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
public protocol AccessoryService: AnyObject {
    
    static var type: BluetoothUUID { get }
    
    var serviceHandle: UInt16 { get }
    
    var characteristics: [AnyManagedCharacteristic] { get async }
}

public struct AnyManagedCharacteristic: Equatable, Hashable {
    
    public let handle: UInt16
    
    public let value: ManagedCharacteristicValue
    
    public let properties: BitMaskOptionSet<CharacteristicProperty>
    
    internal init(
        handle: UInt16,
        value: ManagedCharacteristicValue,
        properties: BitMaskOptionSet<CharacteristicProperty>
    ) {
        self.handle = handle
        self.value = value
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
    
    public private(set) var wrappedValue: Characteristic.Value

    public var projectedValue: AnyManagedCharacteristic {
        .init(handle: valueHandle, value: .single(wrappedValue.characteristicValue), properties: Characteristic.properties)
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
        .init(handle: valueHandle, value: wrappedValue.flatMap { .single($0.characteristicValue) } ?? .none, properties: Characteristic.properties)
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
    
    public private(set) var wrappedValue: [Characteristic.Value]
    
    public var projectedValue: AnyManagedCharacteristic {
        .init(handle: valueHandle, value: .list(wrappedValue.map { $0.characteristicValue }), properties: Characteristic.properties)
    }
}