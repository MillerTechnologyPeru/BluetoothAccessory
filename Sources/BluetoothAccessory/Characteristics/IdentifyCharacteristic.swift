//
//  IdentifyCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public struct IdentifyCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: CharacteristicType { .identify }
    
    public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.write]
    
    public static var encryption: CharacteristicEncryption { .none }
    
    public init(value: Bool = false) {
        self.value = value
    }
    
    public var value: Bool
}
