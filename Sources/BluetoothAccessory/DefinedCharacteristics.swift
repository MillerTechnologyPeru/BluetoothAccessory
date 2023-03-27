//
//  DefinedCharacteristics.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth

public extension AccessoryCharacteristic {
    
    static func defined(_ type: CharacteristicType) -> any AccessoryCharacteristic.Type {
        type.accessoryType
    }
}

public extension CharacteristicType {
    
    var accessoryType: any AccessoryCharacteristic.Type {
        guard let characteristicType = AccessoryCharacteristicCache.characteristicsByType[self] else {
            fatalError("Missing implementation for \(self)")
        }
        return characteristicType
    }
}

internal struct AccessoryCharacteristicCache {
    
    static let characteristicsByType: [CharacteristicType: any AccessoryCharacteristic.Type] = {
        // map values to characteristic
        var mapped = [CharacteristicType: any AccessoryCharacteristic.Type]()
        for characteristic in defined {
            guard let type = CharacteristicType(uuid: characteristic.type) else {
                assertionFailure()
                continue
            }
            mapped[type] = characteristic
        }
        return mapped
    }()
    
    static let defined: [any AccessoryCharacteristic.Type] = {
        var characteristics = [any AccessoryCharacteristic.Type]()
        characteristics += [
            IdentifierCharacteristic.self,
            NameCharacteristic.self,
            AccessoryTypeCharacteristic.self,
            IdentifyCharacteristic.self,
            ManufacturerCharacteristic.self,
            ModelCharacteristic.self,
            SerialNumberCharacteristic.self,
            SoftwareVersionCharacteristic.self,
            MetadataCharacteristic.self,
            HardwareVersionCharacteristic.self
        ]
        characteristics += [
            CryptoHashCharacteristic.self,
            SetupCharacteristic.self,
            AuthenticateCharacteristic.self,
            CreateNewKeyCharacteristic.self,
            ConfirmNewKeyCharacteristic.self,
            KeysCharacteristic.self,
            RemoveKeyCharacteristic.self,
            
        ]
        characteristics += [
            StatusLowBatteryCharacteristic.self,
            BatteryLevelCharacteristic.self,
            ChargingStateCharacteristic.self,
            BatteryVoltageCharacteristic.self,
            BatteryChargingCurrentCharacteristic.self
        ]
        characteristics += [
            PowerStateCharacteristic.self
        ]
        return characteristics
    }()
}
