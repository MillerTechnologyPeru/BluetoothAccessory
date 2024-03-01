//
//  CurrentRelativeHumidityCharacteristic.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Current Relative Humidity Characteristic
public struct CurrentRelativeHumidityCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .currentRelativeHumidity) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .percentage }
    
    public init(value: Float) {
        self.value = value
    }
    
    public var value: Float
}
