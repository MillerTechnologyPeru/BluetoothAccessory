//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//


import Foundation
import Bluetooth
import GATT

/// Confirm New Key Characteristic
public struct ConfirmNewKeyCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .confirmKey) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: ConfirmNewKeyRequest) {
        self.value = value
    }
    
    public var value: ConfirmNewKeyRequest
}

// MARK: - Supporting Types

public struct ConfirmNewKeyRequest: Equatable, Hashable, Codable {
    
    /// New key private key data.
    public let secret: KeyData
    
    public init(secret: KeyData) {
        self.secret = secret
    }
}

extension ConfirmNewKeyRequest: CharacteristicTLVCodable { }

// MARK: - Central

public extension CentralManager {
    
    /// Confirm a new key for the accessory.
    func confirmKey(
        _ request: ConfirmNewKeyRequest,
        characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws {
        try await writeEncrypted(
            ConfirmNewKeyCharacteristic(value: request),
            for: characteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: key
        )
    }
    
    /// Confirm a new key for the accessory.
    func confirmKey(
        _ invitation: NewKey.Invitation,
        characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> (Key, KeyData) {
        let keyData = KeyData()
        let request = ConfirmNewKeyRequest(secret: keyData)
        let invitationKey = Credential(id: invitation.key.id, secret: invitation.secret)
        try await confirmKey(request, characteristic: characteristic, cryptoHash: cryptoHashCharacteristic, key: invitationKey)
        let newKey = invitation.key.confirm()
        return (newKey, keyData)
    }
}

public extension GATTConnection {
    
    /// Confirm a new key for the accessory.
    func confirmKey(
        _ request: ConfirmNewKeyRequest,
        key: Credential
    ) async throws {
        let characteristic = try self.cache.characteristic(.confirmKey, service: .authentication)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        try await self.central.confirmKey(request, characteristic: characteristic, cryptoHash: cryptoHash, key: key)
    }
    
    /// Confirm a new key for the accessory.
    func confirmKey(
        _ invitation: NewKey.Invitation
    ) async throws -> (Key, KeyData) {
        let characteristic = try self.cache.characteristic(.confirmKey, service: .authentication)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        return try await self.central.confirmKey(invitation, characteristic: characteristic, cryptoHash: cryptoHash)
    }
}

