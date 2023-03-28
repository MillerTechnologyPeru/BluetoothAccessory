//
//  CreateNewKeyCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

/// Create New Key Characteristic
public struct CreateNewKeyCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .createKey) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: CreateNewKeyRequest) {
        self.value = value
    }
    
    public var value: CreateNewKeyRequest
}

// MARK: - Supporting Types

public struct CreateNewKeyRequest: Equatable, Hashable, Codable {
    
    /// New Key identifier
    public let id: UUID
    
    /// The name of the new key.
    public let name: String
    
    /// The permission of the new key.
    public let permission: Permission
    
    /// Expiration of temporary new key request.
    public let expiration: Date
    
    /// Shared secret for encrypting the new key.
    public let secret: KeyData
}

extension CreateNewKeyRequest: CharacteristicTLVCodable { }

public extension CreateNewKeyRequest {
    
    init(key: NewKey, secret: KeyData) {
        
        self.id = key.id
        self.name = key.name
        self.permission = key.permission
        self.expiration = key.expiration
        self.secret = secret
    }
}

public extension NewKey {
    
    init(request: CreateNewKeyRequest, created: Date = Date()) {
        
        self.id = request.id
        self.name = request.name
        self.permission = request.permission
        self.expiration = request.expiration
        self.created = created.removingMiliseconds
    }
}

// MARK: - Central

public extension CentralManager {
    
    /// Create a new key for the accessory.
    func createKey(
        _ request: CreateNewKeyRequest,
        characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws {
        try await writeEncrypted(
            CreateNewKeyCharacteristic(value: request),
            for: characteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: key
        )
    }
    
    /// Create a new key for the accessory.
    func createKey(
        _ newKey: NewKey,
        secret: KeyData = KeyData(),
        device: UUID,
        characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> NewKey.Invitation {
        let request = CreateNewKeyRequest(key: newKey, secret: secret)
        try await createKey(request, characteristic: characteristic, cryptoHash: cryptoHashCharacteristic, key: key)
        return NewKey.Invitation(
            device: device,
            key: newKey,
            secret: secret
        )
    }
}

public extension GATTConnection {
    
    /// Create a new key for the accessory.
    func createKey(
        _ request: CreateNewKeyRequest,
        key: Credential
    ) async throws {
        let characteristic = try self.cache.characteristic(.createKey, service: .authentication)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        try await self.central.createKey(request, characteristic: characteristic, cryptoHash: cryptoHash, key: key)
    }
    
    /// Create a new key for the accessory.
    func createKey(
        _ newKey: NewKey,
        secret: KeyData = KeyData(),
        device: UUID,
        key: Credential
    ) async throws -> NewKey.Invitation {
        let characteristic = try self.cache.characteristic(.createKey, service: .authentication)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        return try await self.central.createKey(newKey, secret: secret, device: device, characteristic: characteristic, cryptoHash: cryptoHash, key: key)
    }
}
