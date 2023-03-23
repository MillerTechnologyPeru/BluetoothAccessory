//
//  HardwareVersionCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

public struct HardwareVersionCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .hardwareRevision) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read] }
    
    public init(value: String) {
        self.value = value
    }
    
    public var value: String
}
