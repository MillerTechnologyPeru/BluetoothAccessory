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
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}
