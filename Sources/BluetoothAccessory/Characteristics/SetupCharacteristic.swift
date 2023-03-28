//
//  SetupCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

/// Setup Characteristic
public struct SetupCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .setup) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: SetupRequest) {
        self.value = value
    }
    
    public var value: SetupRequest
}

// MARK: - Supporting Types

public struct SetupRequest: Equatable, Hashable, Codable {
    
    /// Key identifier
    public let id: UUID
    
    /// Key secret
    public let secret: KeyData
    
    /// Key username
    public let name: String
    
    public init(
        id: UUID = UUID(),
        secret: KeyData = KeyData(),
        name: String
    ) {
        self.id = id
        self.secret = secret
        self.name = name
    }
}

extension SetupRequest: CharacteristicTLVCodable { }

public extension Key {
    
    /// Initialize a new owner key from a setup request.
    init(setup: SetupRequest, created: Date = Date()) {
        self.init(
            id: setup.id,
            name: setup.name,
            created: created.removingMiliseconds,
            permission: .owner
        )
    }
}

// MARK: - Central

public extension CentralManager {
    
    /// Setup an accessory
    func setup(
        _ request: SetupRequest,
        using sharedSecret: KeyData,
        characteristic setupCharacteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>
    ) async throws {
        // write setup request
        let credentials = Credential(
            id: .zero,
            secret: sharedSecret
        )
        try await writeEncrypted(
            SetupCharacteristic(value: request),
            for: setupCharacteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: credentials
        )
    }
}

public extension GATTConnection {
    
    func setup(
        _ request: SetupRequest,
        using sharedSecret: KeyData
    ) async throws {
        let cryptoHashCharacteristic = try self.cache.characteristic(.cryptoHash, service: .authentication)
        let setupCharacteristic = try self.cache.characteristic(.setup, service: .authentication)
        try await self.central.setup(request, using: sharedSecret, characteristic: setupCharacteristic, cryptoHash: cryptoHashCharacteristic)
    }
}
