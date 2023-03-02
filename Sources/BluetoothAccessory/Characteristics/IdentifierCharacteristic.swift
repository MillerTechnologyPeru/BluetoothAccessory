//
//  IdentifierCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

@propertyWrapper
public struct IdentifierCharacteristic: Equatable, Hashable {
    
    public static var type: CharacteristicType { .identifier }
    
    public static var properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> { [.read] }
    
    public static var format: CharacteristicFormat { .uuid }
    
    public static var encryption: CharacteristicEncryption { .none }
    
    public init(wrappedValue: UUID = UUID()) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: UUID
}
