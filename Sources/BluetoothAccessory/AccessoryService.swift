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
    
    static var isPrimary: Bool { get }
    
    static var characteristics: [any AccessoryCharacteristic.Type] { get }
    
    var characteristicValues: [ManagedCharacteristicValue] { get }
}

public extension AccessoryService {
    
    static var isPrimary: Bool { true }
}

public enum ManagedCharacteristicValue {
    
    case single(CharacteristicValue)
    case list([CharacteristicValue])
}

@propertyWrapper
public struct ManagedCharacteristic <T: AccessoryCharacteristic> {
    
    public init(wrappedValue: T.Value) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: T.Value
    
    public var projectedValue: ManagedCharacteristicValue {
        return .single(wrappedValue.characteristicValue)
    }
}

@propertyWrapper
public struct ManagedListCharacteristic <T: AccessoryCharacteristic> {
    
    public init(wrappedValue: [T.Value] = []) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: [T.Value]
    
    public var projectedValue: ManagedCharacteristicValue {
        return .list(wrappedValue.map { $0.characteristicValue })
    }
}
