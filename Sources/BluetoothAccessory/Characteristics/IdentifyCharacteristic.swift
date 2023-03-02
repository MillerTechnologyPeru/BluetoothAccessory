//
//  IdentifyCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

@propertyWrapper
public struct IdentifyCharacteristic: Equatable, Hashable {
    
    public static var type: CharacteristicType { .identify }
    
    public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.write]
    
    public init(wrappedValue: Bool = false) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: Bool
}
