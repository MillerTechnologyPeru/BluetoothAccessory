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
        self.created = created
    }
}
