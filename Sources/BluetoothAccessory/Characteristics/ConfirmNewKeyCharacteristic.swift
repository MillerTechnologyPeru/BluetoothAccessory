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
