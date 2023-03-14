//
//  NameCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public struct NameCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: CharacteristicType { .name }
    
    public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.read]
    
    public static var encryption: CharacteristicEncryption { .none }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}
