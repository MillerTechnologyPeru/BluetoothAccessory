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

internal extension CharacteristicType {
    
    var accessoryType: any AccessoryCharacteristic.Type {
        guard let characteristicType = AccessoryCharacteristicCache.characteristicsByType[self] else {
            fatalError("Missing implementation for \(self)")
        }
        return characteristicType
    }
}

internal struct AccessoryCharacteristicCache {
    
    static let characteristicsByType: [CharacteristicType: any AccessoryCharacteristic.Type] = {
        var characteristicsCache = [CharacteristicType: any AccessoryCharacteristic.Type]()
        
        func append<T: AccessoryCharacteristic>(_ characteristic: T.Type) {
            guard let type = CharacteristicType(uuid: characteristic.type) else {
                assertionFailure()
                return
            }
            characteristicsCache[type] = characteristic
        }
        func append(_ characteristics: any AccessoryCharacteristic.Type ...) {
            for characteristic in characteristics {
                guard let type = CharacteristicType(uuid: characteristic.type) else {
                    assertionFailure()
                    return
                }
                characteristicsCache[type] = characteristic
            }
        }
        // Information
        append(
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
        )
        
        // Authorization
        append(
            CryptoHashCharacteristic.self,
            ConfigurationStateCharacteristic.self,
            SetupCharacteristic.self,
            AuthenticateCharacteristic.self,
            CreateNewKeyCharacteristic.self,
            ConfirmNewKeyCharacteristic.self,
            KeysCharacteristic.self,
            RemoveKeyCharacteristic.self
        )
        
        // Battery
        append(
            StatusLowBatteryCharacteristic.self,
            BatteryLevelCharacteristic.self,
            ChargingStateCharacteristic.self,
            BatteryVoltageCharacteristic.self,
            BatteryChargingCurrentCharacteristic.self
        )
        
        // Outlet
        append(PowerStateCharacteristic.self)
        
        return characteristicsCache
    }()
}
