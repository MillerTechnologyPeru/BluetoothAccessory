//
//  TemperatureSensorCharacteristic.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Current Temperature Characteristic
public struct CurrentTemperatureCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .currentTemperature) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .celsius }
    
    public init(value: Float) {
        self.value = value
    }
    
    public var value: Float
}
