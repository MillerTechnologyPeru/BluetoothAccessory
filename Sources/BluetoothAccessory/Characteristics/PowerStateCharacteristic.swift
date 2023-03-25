//
//  PowerStateCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/24/23.
//

import Foundation
import Bluetooth
import GATT

public struct PowerStateCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .powerState) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .write, .encrypted] }
    
    public init(value: Bool = false) {
        self.value = value
    }
    
    public var value: Bool
}

// MARK: - Central

public extension CentralManager {
    
    /// Read accessory power state.
    func readPowerState(
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> Bool {
        return try await readEncryped(
            PowerStateCharacteristic.self,
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        ).value
    }
    
    /// Write accessory power state.
    func writePowerState(
        _ newValue: Bool,
        characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws {
        try await writeEncrypted(
            PowerStateCharacteristic(value: newValue),
            for: characteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: key
        )
    }
}

public extension GATTConnection {
    
    /// Read accessory power state.
    func readPowerState(
        service: BluetoothUUID,
        key: Credential
    ) async throws -> Bool {
        let characteristic = try self.cache.characteristic(BluetoothUUID(characteristic: .powerState), service: service)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        let authentication = try self.cache.characteristic(.authenticate, service: .authentication)
        return try await self.central.readPowerState(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHash,
            authentication: authentication,
            key: key
        )
    }
    
    /// Write accessory power state.
    func writePowerState(
        _ newValue: Bool,
        service: BluetoothUUID,
        key: Credential
    ) async throws {
        let characteristic = try self.cache.characteristic(BluetoothUUID(characteristic: .powerState), service: service)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        try await self.central.writePowerState(newValue, characteristic: characteristic, cryptoHash: cryptoHash, key: key)
    }
}
