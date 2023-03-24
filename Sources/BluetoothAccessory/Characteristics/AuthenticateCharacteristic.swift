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
    
    /// Random data
    public let nonce: Nonce
    
    /// Date
    public let date: Date
    
    /// Service of the characteristic for encrypted read
    public let service: BluetoothUUID
    
    /// Characteristic for encrypted read.
    public let characteristic: BluetoothUUID
    
    public init(
        nonce: Nonce = Nonce(),
        date: Date = Date(),
        service: BluetoothUUID,
        characteristic: BluetoothUUID
    ) {
        self.nonce = nonce
        self.date = date.removingMiliseconds
        self.service = service
        self.characteristic = characteristic
    }
}

extension AuthenticationRequest: CharacteristicTLVCodable { }

// MARK: - Central

public extension CentralManager {
    
    /// Setup an accessory
    func authenticate(
        characteristic: BluetoothUUID,
        service: BluetoothUUID,
        authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key credentials: Credential
    ) async throws {
        try await writeEncrypted(
            AuthenticateCharacteristic(
                value: AuthenticationRequest(
                    service: service,
                    characteristic: characteristic
                )
            ),
            for: authenticationCharacteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: credentials
        )
    }
}
