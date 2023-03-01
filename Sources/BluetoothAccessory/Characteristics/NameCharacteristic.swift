//
//  NameCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

struct NameCharacteristic: Equatable, Hashable {
    
    public static var type: CharacteristicType { .name }
    
    public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.read]
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
    
}
