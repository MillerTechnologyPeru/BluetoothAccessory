//
//  BluetoothUUID.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/28/23.
//

import Foundation
import Bluetooth
import BluetoothAccessory

internal extension BluetoothUUID {
    
    private struct Cache {
        static let serviceTypes = BluetoothUUID.mapped { BluetoothUUID(service: $0) }
        static let characteristicTypes = BluetoothUUID.mapped { BluetoothUUID(characteristic: $0) }
    }
    
    static var accessoryServiceTypes: [BluetoothUUID: BluetoothAccessory.ServiceType] {
        return Cache.serviceTypes
    }
    
    static var accessoryCharacteristicType: [BluetoothUUID: BluetoothAccessory.CharacteristicType] {
        return Cache.characteristicTypes
    }
}

internal extension BluetoothUUID {
    
    static func mapped<T: Hashable & CaseIterable>(_ uuid: (T) -> BluetoothUUID) -> [BluetoothUUID: T] {
        var output = [BluetoothUUID: T]()
        output.reserveCapacity(T.allCases.count)
        for value in T.allCases {
            output[uuid(value)] = value
        }
        return output
    }
}
