//
//  IdentifyCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public struct IdentifyCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .identify) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: Bool = false) {
        self.value = value
    }
    
    public var value: Bool
}

// MARK: - Central

public extension CentralManager {
    
    /// Read accessory identifier.
    func identify(
        characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws {
        try await writeEncrypted(
            IdentifyCharacteristic(value: true),
            for: characteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: key
        )
    }
}

public extension GATTConnection {
    
    /// Read accessory identifier.
    func identify(
        key: Credential
    ) async throws {
        let characteristic = try self.cache.characteristic(.identify, service: .information)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        try await self.central.identify(characteristic: characteristic, cryptoHash: cryptoHash, key: key)
    }
}
