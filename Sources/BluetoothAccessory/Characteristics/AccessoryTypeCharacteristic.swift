//
//  AccessoryTypeCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/2/23.
//

import Foundation
import Bluetooth
import GATT

@propertyWrapper
public struct AccessoryTypeCharacteristic: Equatable, Hashable {
    
    public static var type: CharacteristicType { .accessoryType }
    
    public static var properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> { [.read] }
    
    public static var format: CharacteristicFormat { .uint16 }
    
    public static var encryption: CharacteristicEncryption { .none }
    
    public init(wrappedValue: AccessoryType) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: AccessoryType
}
