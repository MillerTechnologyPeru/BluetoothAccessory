//
//  ChargingStateCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

public struct ChargingStateCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .chargingState) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public init(value: ChargingState = .notCharging) {
        self.value = value
    }
    
    public var value: ChargingState
}

// MARK: - Supporting Types

/// Battery Charging State
public enum ChargingState: UInt8, Codable, CaseIterable, CharacteristicCodable {
    
    /// Not charging
    case notCharging = 0
    
    /// Currently charging
    case charging = 1
    
    /// Not chargeable
    case notChargeable = 2
}

// MARK: - Central

public extension CentralManager {
    
    /// Read battery charging state.
    func readChargingState(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> ChargingState {
        let characteristic = try await read(ChargingStateCharacteristic.self, characteristic: characteristic)
        return characteristic.value
    }
}

public extension GATTConnection {
    
    /// Read battery charging state.
    func readChargingState() async throws -> ChargingState {
        let characteristic = try self.cache.characteristic(.chargingState, service: .battery)
        return try await self.central.readChargingState(characteristic: characteristic)
    }
}
