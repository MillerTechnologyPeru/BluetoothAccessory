//
//  StatusLowBatteryCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

public struct StatusLowBatteryCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .statusLowBattery) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public init(value: StatusLowBattery = .normal) {
        self.value = value
    }
    
    public var value: StatusLowBattery
}

// MARK: - Supporting Types

/// Low Battery Status
public enum StatusLowBattery: UInt8, Codable, CaseIterable, CharacteristicCodable {
    
    /// Battery is normal
    case normal = 0
    
    /// Battery is low
    case low = 1
    
    /// Battery needs servicing
    case service = 2
}

// MARK: - Central

public extension CentralManager {
    
    /// Read battery level value.
    func readStatusLowBattery(
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> StatusLowBattery {
        return try await readEncryped(
            StatusLowBatteryCharacteristic.self,
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        ).value
    }
}

public extension GATTConnection {
    
    /// Read battery level value.
    func readStatusLowBattery(
        service: BluetoothUUID = BluetoothUUID(service: .battery),
        key: Credential
    ) async throws -> StatusLowBattery {
        let characteristic = try self.cache.characteristic(BluetoothUUID(characteristic: .statusLowBattery), service: service)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        let authentication = try self.cache.characteristic(.authenticate, service: .authentication)
        return try await self.central.readStatusLowBattery(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHash,
            authentication: authentication,
            key: key
        )
    }
}
