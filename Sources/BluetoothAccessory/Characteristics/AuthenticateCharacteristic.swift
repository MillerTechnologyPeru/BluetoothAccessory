//
//  AuthenticateCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

/// Authenticate Characteristic
public struct AuthenticateCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .authenticate) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: AuthenticationRequest) {
        self.value = value
    }
    
    public var value: AuthenticationRequest
}

// MARK: - Supporting Types

public struct AuthenticationRequest: Equatable, Hashable, Codable {
    
    /// Crypto hash
    public let nonce: Nonce
    
    public let date: Date
    
    public init(
        nonce: Nonce = Nonce(),
        date: Date = Date()
    ) {
        self.nonce = nonce
        self.date = date
    }
}

extension AuthenticationRequest: CharacteristicTLVCodable { }
