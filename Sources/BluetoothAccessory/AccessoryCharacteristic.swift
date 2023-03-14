//
//  AccessoryCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/10/23.
//

import Foundation
import Bluetooth
import GATT
#if canImport(BluetoothGATT)
import BluetoothGATT
#endif

/// Bluetooth Accessory Characteristic
public protocol AccessoryCharacteristic {
    
    associatedtype Value: CharacteristicCodable
    
    static var type: CharacteristicType { get }
        
    static var properties: BitMaskOptionSet<CharacteristicProperty> { get }
    
    static var unit: CharacteristicUnit? { get }
        
    init(value: Value)
    
    var value: Value { get }
}

public extension AccessoryCharacteristic {
    
    static var unit: CharacteristicUnit? { nil }
}

public extension AccessoryCharacteristic {
    
    init?(from data: Data) {
        guard let characteristicValue = CharacteristicValue(from: data, format: Value.characteristicFormat),
              let value = Value(characteristicValue: characteristicValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    func encode() -> Data {
        value.characteristicValue.encode()
    }
}

public extension AccessoryCharacteristic {
    
    static var descriptors: [AccessoryDescriptor] {
        [
            .encryption(encryption),
            .format(Value.characteristicFormat),
            unit.flatMap({ .unit($0) })
        ]
        .compactMap { $0 }
    }
}

#if canImport(BluetoothGATT)
public extension AccessoryCharacteristic {
    
    static var permissions: Bluetooth.BitMaskOptionSet<GATTAttribute.Descriptor.Permission> {
        var permissions = Bluetooth.BitMaskOptionSet<GATTAttribute.Descriptor.Permission>()
        return permissions
    }
}

public extension GATTAttribute.Characteristic {
    
    init<T: AccessoryCharacteristic>(_ characteristic: T.Type) {
        var descriptors = characteristic.descriptors.map({ .init($0) })
            + [GATTUserDescription(userDescription: characteristic.type.description).descriptor]
        if characteristic.encryption != .none {
            descriptors.append(GATTFormatDescriptor(format: .init(bluetoothAccessory: T.Value.format), exponent: 0, unit: 0, namespace: 0, description: 0).descriptor)
        }
        self.init(
            uuid: BluetoothUUID(characteristic: characteristic.type),
            value: Data(),
            permissions: characteristic.permissions,
            properties: characteristic.properties,
            descriptors: descriptors
        )
    }
}
#endif
