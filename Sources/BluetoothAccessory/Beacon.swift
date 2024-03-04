//
//  Beacon.swift
//  
//
//  Created by Alsey Coleman Miller on 3/14/23.
//

import Foundation
import Bluetooth

/// Bluetooth Accessory Beacon
public enum AccessoryBeacon: Equatable, Hashable, Sendable, Codable {
    
    /// Generic Beacon advertising the accessory.
    case accessory(UUID? = nil, AccessoryType, GlobalStateNumber)
    
    /// Beacon used for waking up app for state changes.
    case characteristicChanged(CharacteristicType, GlobalStateNumber)
}

public extension AccessoryBeacon {
    
    var accessory: UUID? {
        switch self {
        case let .accessory(uuid, _, _):
            return uuid
        case .characteristicChanged:
            return nil
        }
    }
    
    var accessoryType: AccessoryType? {
        switch self {
        case let .accessory(_, type, _):
            return type
        case .characteristicChanged:
            return nil
        }
    }
    
    var state: GlobalStateNumber {
        switch self {
        case let .accessory(_, _, state):
            return state
        case let .characteristicChanged(_, state):
            return state
        }
    }
}

internal extension AccessoryBeacon {
    
    enum DefinedUUID: UInt32, CaseIterable {
        
        case accessory = 0
        case characteristicChanged = 1
    }
}

internal extension UUID {
    
    init(beacon: AccessoryBeacon.DefinedUUID) {
        self.init(UInt128(bluetoothAccessory: beacon.rawValue))
    }
}

internal extension AccessoryBeacon {
    
    var uuid: UUID {
        switch self {
        case let .accessory(uuid, _, _):
            return uuid ?? UUID(beacon: .accessory)
        case .characteristicChanged:
            return UUID(beacon: .characteristicChanged)
        }
    }
    
    var major: UInt16 {
        switch self {
        case let .accessory(_, accessoryType, _):
            return accessoryType.rawValue
        case let .characteristicChanged(characteristicType, _):
            return characteristicType.rawValue
        }
    }
    
    var minor: UInt16 {
        switch self {
        case let .accessory(_, _, state):
            return state.rawValue
        case let .characteristicChanged(_, state):
            return state.rawValue
        }
    }
}

public extension AccessoryBeacon {
    
    init?(beacon: AppleBeacon) {
        switch beacon.uuid {
        case UUID(beacon: .characteristicChanged):
            guard let characteristicType = CharacteristicType(rawValue: beacon.major) else {
                return nil
            }
            let state = GlobalStateNumber(rawValue: beacon.minor)
            self = .characteristicChanged(characteristicType, state)
        default:
            let uuid = beacon.uuid == UUID(beacon: .accessory) ? nil : beacon.uuid
            guard let accessoryType = AccessoryType(rawValue: beacon.major) else {
                return nil
            }
            let state = GlobalStateNumber(rawValue: beacon.minor)
            self = .accessory(uuid, accessoryType, state)
        }
    }
}

public extension AppleBeacon {
    
    init(bluetoothAccessory beacon: AccessoryBeacon, rssi: Int8) {
        self.init(
            uuid: beacon.uuid,
            major: beacon.major,
            minor: beacon.minor,
            rssi: rssi
        )
    }
}
