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
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> ChargingState {
        return try await readEncryped(
            ChargingStateCharacteristic.self,
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        ).value
    }
}

public extension GATTConnection {
    
    /// Read battery charging state.
    func readChargingState(
        service: BluetoothUUID = BluetoothUUID(service: .battery),
        key: Credential
    ) async throws -> ChargingState {
        let characteristic = try self.cache.characteristic(BluetoothUUID(characteristic: .chargingState), service: service)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        let authentication = try self.cache.characteristic(.authenticate, service: .authentication)
        return try await self.central.readChargingState(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHash,
            authentication: authentication,
            key: key
        )
    }
}
