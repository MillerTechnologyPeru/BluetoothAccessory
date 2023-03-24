//
//  CharacteristicProperty.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Accessory Characteristic Property
public enum CharacteristicProperty: UInt8, Codable, CaseIterable, BitMaskOption {
    
    /// Value can be read.
    case read                   = 0b00000001
    
    /// Value can be written.
    case write                  = 0b00000010
    
    /// Write without Response
    case writeWithoutResponse   = 0b00000100
    
    /// Notifications for changed values
    case notification           = 0b00001000
    
    /// Characteristic is encrypted, cannot read or write using normal GATT operations.
    case encrypted              = 0b00010000
    
    /// Value is a sequence.
    case list                   = 0b00100000
}
