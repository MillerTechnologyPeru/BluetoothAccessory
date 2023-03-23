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
    
    var characteristicValues: [ManagedCharacteristicValue] { get async }
}

public enum ManagedCharacteristicValue {
    
    case single(CharacteristicValue)
    case list([CharacteristicValue])
}

@propertyWrapper
public struct ManagedCharacteristic <Characteristic: AccessoryCharacteristic, Peripheral: AccessoryPeripheralManager> {
    
    weak var peripheral: Peripheral?
    
    let valueHandle: UInt16
    
    public init(
        wrappedValue: Characteristic.Value,
        peripheral: Peripheral,
        valueHandle: UInt16
    ) async {
        assert(Characteristic.properties.contains(.list) == false)
        self.wrappedValue = wrappedValue
        self.peripheral = peripheral
        self.valueHandle = valueHandle
        await setValue(wrappedValue) // update DB
    }
    
    public private(set) var wrappedValue: Characteristic.Value
    
    public var projectedValue: ManagedCharacteristicValue {
        .single(wrappedValue.characteristicValue)
    }
    
    public mutating func setValue(_ newValue: Characteristic.Value) async {
        self.wrappedValue = newValue
        // write plain text
        if Characteristic.gattProperties.contains(.read) {
            await peripheral?.write(newValue.characteristicValue.encode(), forCharacteristic: valueHandle)
        }
    }
}

/*
@propertyWrapper
public struct ManagedListCharacteristic <T: AccessoryCharacteristic> {
    
    let peripheral: Peripheral
    
    public init(wrappedValue: [T.Value] = []) {
        assert(Characteristic.properties.contains(.list))
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: [T.Value]
    
}
*/
