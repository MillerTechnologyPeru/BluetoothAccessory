//
//  AccessoryCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/10/23.
//

import Foundation
import Bluetooth
import GATT

/// Bluetooth Accessory Characteristic
public protocol AccessoryCharacteristic {
    
    associatedtype Value: CharacteristicCodable
    
    static var type: CharacteristicType { get }
        
    static var properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> { get }
        
    static var encryption: CharacteristicEncryption { get }
    
    //var userDescription: String { get }
    
    init(value: Value)
    
    var value: Value { get }
}

public extension AccessoryCharacteristic {
    
    init?(from data: Data) {
        guard let characteristicValue = CharacteristicValue(from: data, format: Value.characteristicFormat),
              let value = Value(characteristicValue: characteristicValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    func encode() -> Data {
        value.characteristicValue.encode()
    }
}
