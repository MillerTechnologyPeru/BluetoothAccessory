//
//  AccessoryTypeCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/2/23.
//

import Foundation
import Bluetooth
import GATT

public struct AccessoryTypeCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: CharacteristicType { .accessoryType }
    
    public static var properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> { [.read] }
        
    public static var encryption: CharacteristicEncryption { .none }
    
    public init(value: AccessoryType) {
        self.value = value
    }
    
    public var value: AccessoryType
}
