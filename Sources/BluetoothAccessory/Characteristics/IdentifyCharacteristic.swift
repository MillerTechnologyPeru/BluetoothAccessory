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
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: Bool = false) {
        self.value = value
    }
    
    public var value: Bool
}
