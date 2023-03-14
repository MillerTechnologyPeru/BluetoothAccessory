//
//  IdentifierCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public struct IdentifierCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: CharacteristicType { .identifier }
    
    public static var properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> { [.read] }
        
    public static var encryption: CharacteristicEncryption { .none }
    
    public init(value: UUID = UUID()) {
        self.value = value
    }
    
    public var value: UUID
}
