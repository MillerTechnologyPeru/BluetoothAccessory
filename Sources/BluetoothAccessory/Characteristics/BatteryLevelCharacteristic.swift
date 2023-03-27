//
//  BatteryLevelCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Battery Level Characteristic
public struct BatteryLevelCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .batteryLevel) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .percentage }
    
    public init(value: UInt8 = 100) {
        assert(value <= 100)
        self.value = value
    }
    
    public var value: UInt8 {
        didSet {
            // Validate battery level under 100%
            assert(value <= 100, "Battery level must not exceed 100%")
        }
    }
}

// MARK: - Central

public extension CentralManager {
    
    /// Read battery level value.
    func readBatteryLevel(
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> UInt8 {
        return try await readEncryped(
            BatteryLevelCharacteristic.self,
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
    func readBatteryLevel(
        service: BluetoothUUID = BluetoothUUID(service: .battery),
        key: Credential
    ) async throws -> UInt8 {
        let characteristic = try self.cache.characteristic(BluetoothUUID(characteristic: .batteryLevel), service: service)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        let authentication = try self.cache.characteristic(.authenticate, service: .authentication)
        return try await self.central.readBatteryLevel(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHash,
            authentication: authentication,
            key: key
        )
    }
}
