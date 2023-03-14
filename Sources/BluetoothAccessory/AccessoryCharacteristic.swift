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
