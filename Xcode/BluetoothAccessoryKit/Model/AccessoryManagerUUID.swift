//
//  AccessoryManagerUUID.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/27/23.
//

import Foundation
import Bluetooth
import BluetoothAccessory

internal extension AccessoryManager {
    
    func loadServiceTypes() -> [BluetoothUUID: BluetoothAccessory.ServiceType] {
        var serviceTypes = [BluetoothUUID: ServiceType]()
        serviceTypes.reserveCapacity(ServiceType.allCases.count)
        for service in ServiceType.allCases {
            let uuid = BluetoothUUID(service: service)
            serviceTypes[uuid] = service
        }
        assert(serviceTypes.count == ServiceType.allCases.count)
        return serviceTypes
    }
    
    func loadCharacteristicTypes() -> [BluetoothUUID: BluetoothAccessory.CharacteristicType] {
        var characteristicTypes = [BluetoothUUID: CharacteristicType]()
        characteristicTypes.reserveCapacity(CharacteristicType.allCases.count)
        for characteristic in CharacteristicType.allCases {
            let uuid = BluetoothUUID(characteristic: characteristic)
            characteristicTypes[uuid] = characteristic
        }
        assert(characteristicTypes.count == CharacteristicType.allCases.count)
        return characteristicTypes
    }
}
