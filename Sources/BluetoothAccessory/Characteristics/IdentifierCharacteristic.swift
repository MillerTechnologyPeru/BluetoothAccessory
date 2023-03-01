//
//  IdentifierCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

struct IdentifierCharacteristic: Equatable, Hashable {
    
    public static var type: CharacteristicType { .identifier }
    
    public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.read]
    
    public init(value: Bool = false) {
        self.value = value
    }
    
    public var value: Bool
    
}
