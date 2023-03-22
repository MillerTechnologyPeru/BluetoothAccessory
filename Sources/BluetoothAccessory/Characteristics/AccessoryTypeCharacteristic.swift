//
//  AccessoryTypeCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/2/23.
//

import Foundation
import Bluetooth
import GATT

public struct AccessoryTypeCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .accessoryType) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: AccessoryType) {
        self.value = value
    }
    
    public var value: AccessoryType
}
