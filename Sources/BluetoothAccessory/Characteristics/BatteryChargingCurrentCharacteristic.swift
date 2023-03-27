//
//  BatteryChargingCurrentCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Battery Charging Current Characteristic
public struct BatteryChargingCurrentCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .batteryChargingCurrent) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .amps }
    
    public init(value: UInt8) {
        self.value = value
    }
    
    public var value: UInt8
}

// MARK: - Central

public extension CentralManager {
    
    /// Read Battery Charging Current value.
    func readBatteryChargingCurrent(
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> UInt8 {
        return try await readEncryped(
            BatteryChargingCurrentCharacteristic.self,
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        ).value
    }
}

public extension GATTConnection {
    
    /// Read Battery Charging Current value.
    func readBatteryChargingCurrent(
        service: BluetoothUUID = BluetoothUUID(service: .battery),
        key: Credential
    ) async throws -> UInt8 {
        let characteristic = try self.cache.characteristic(BluetoothUUID(characteristic: .batteryChargingCurrent), service: service)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        let authentication = try self.cache.characteristic(.authenticate, service: .authentication)
        return try await self.central.readBatteryChargingCurrent(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHash,
            authentication: authentication,
            key: key
        )
    }
}
