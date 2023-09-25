//
//  Beacon.swift
//  
//
//  Created by Alsey Coleman Miller on 3/14/23.
//

import Foundation
import Bluetooth

/// Bluetooth Accessory Beacon
public enum AccessoryBeacon: Equatable, Hashable {
    
    /// Identifier
    case id(UUID)
    
    /// Characteristic changed
    case characteristicChanged(UUID, CharacteristicType)
    
    // Setup mode
    case setup(UUID, AccessoryType)
}

public extension AccessoryBeacon {
    
    var uuid: UUID {
        switch self {
        case let .id(uuid):
            return uuid
        case let .characteristicChanged(uuid, _):
            return uuid
        case let .setup(uuid, _):
            return uuid
        }
    }
    
    var major: UInt16 {
        switch self {
        case .id:
            return 0x00
        case .characteristicChanged:
            return 0x01
        case .setup:
            return 0x02
        }
    }
    
    var minor: UInt16 {
        switch self {
        case .id:
            return 0x00
        case let .characteristicChanged(_, type):
            return type.rawValue
        case let .setup(_, type):
            return type.rawValue
        }
    }
}

public extension AppleBeacon {
    
    init(bluetoothAccessory beacon: AccessoryBeacon, rssi: Int8) {
        self.init(uuid: beacon.uuid, major: beacon.major, minor: beacon.minor, rssi: rssi)
    }
}

public extension AccessoryBeacon {
    
    init?(beacon: AppleBeacon) {
        switch beacon.major {
        case 0x00:
            guard beacon.minor == 0x00 else {
                return nil
            }
            self = .id(beacon.uuid)
        case 0x01:
            guard let characteristicType = CharacteristicType(rawValue: beacon.minor) else {
                return nil
            }
            self = .characteristicChanged(beacon.uuid, characteristicType)
        case 0x02:
            guard let accessoryType = AccessoryType(rawValue: beacon.minor) else {
                return nil
            }
            self = .setup(beacon.uuid, accessoryType)
        default:
            return nil
        }
    }
}
