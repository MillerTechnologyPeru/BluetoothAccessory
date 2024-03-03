//
//  Beacon.swift
//  
//
//  Created by Alsey Coleman Miller on 3/14/23.
//

import Foundation
import Bluetooth

/// Bluetooth Accessory Beacon
public struct AccessoryBeacon: Equatable, Hashable, Sendable, Codable {
    
    public let id: UUID
    
    public let type: AccessoryType
    
    public var state: GlobalStateNumber
    
    public init(id: UUID, type: AccessoryType, state: GlobalStateNumber) {
        self.id = id
        self.type = type
        self.state = state
    }
}

public extension AccessoryBeacon {
    
    init(beacon: AppleBeacon) {
        self.init(
            id: beacon.uuid,
            type: AccessoryType(rawValue: beacon.major) ?? .other,
            state: GlobalStateNumber(rawValue: beacon.minor)
        )
    }
}

public extension AppleBeacon {
    
    init(bluetoothAccessory beacon: AccessoryBeacon, rssi: Int8) {
        self.init(
            uuid: beacon.id,
            major: beacon.type.rawValue,
            minor: beacon.state.rawValue,
            rssi: rssi
        )
    }
}
