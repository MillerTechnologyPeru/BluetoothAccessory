//
//  AuthenticationService.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

#if canImport(BluetoothGATT)
import Foundation
import Bluetooth

/// Accessory Authentication Service
public struct AuthenticationService: AccessoryService {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .authentication) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<CryptoHashCharacteristic>
    public var cryptoHash: Nonce
    
    @ManagedCharacteristic<ConfigurationStateCharacteristic>
    public var isConfigured: Bool
    
    @ManagedWriteOnlyCharacteristic<SetupCharacteristic>
    public var setup: SetupRequest?
    
    @ManagedWriteOnlyCharacteristic<AuthenticateCharacteristic>
    public var authenticate: AuthenticationRequest?
    
    @ManagedWriteOnlyCharacteristic<CreateNewKeyCharacteristic>
    public var createKey: CreateNewKeyRequest?
    
    @ManagedWriteOnlyCharacteristic<ConfirmNewKeyCharacteristic>
    public var confirmKey: ConfirmNewKeyRequest?
    
    @ManagedListCharacteristic<KeysCharacteristic>
    public var keys: [KeysCharacteristic.Item]
    
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        cryptoHash: Nonce = Nonce(),
        isConfigured: Bool = false,
        keys: [KeysCharacteristic.Item] = []
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: AuthenticationService.self,
            with: [
                CryptoHashCharacteristic.self,
                ConfigurationStateCharacteristic.self,
                ConfigurationStateCharacteristic.self,
                SetupCharacteristic.self,
                AuthenticateCharacteristic.self,
                CreateNewKeyCharacteristic.self,
                ConfirmNewKeyCharacteristic.self,
                KeysCharacteristic.self
            ]
        )
        self.serviceHandle = serviceHandle
        _cryptoHash = .init(wrappedValue: cryptoHash, valueHandle: valueHandles[0])
        _isConfigured = .init(wrappedValue: isConfigured, valueHandle: valueHandles[1])
        _setup = .init(valueHandle: valueHandles[2])
        _authenticate = .init(valueHandle: valueHandles[3])
        _createKey = .init(valueHandle: valueHandles[4])
        _confirmKey = .init(valueHandle: valueHandles[5])
        _keys = .init(wrappedValue: keys, valueHandle: valueHandles[6])
    }
}

public extension AuthenticationService {
    
    var characteristics: [AnyManagedCharacteristic] {
        [
            $cryptoHash,
            $setup,
            $authenticate,
            $createKey,
            $confirmKey,
            $keys
        ]
    }
    
    mutating func update(characteristic: UInt16, with newValue: ManagedCharacteristicValue) -> Bool {
        switch (characteristic, newValue) {
        case (_setup.valueHandle, .single(let newValue)):
            guard let request = SetupRequest(characteristicValue: newValue) else {
                return false
            }
            self.setup = request
            return true
        case (_authenticate.valueHandle, .single(let newValue)):
            guard let request = AuthenticationRequest(characteristicValue: newValue) else {
                return false
            }
            self.authenticate = request
            return true
        case (_createKey.valueHandle, .single(let newValue)):
            guard let request = CreateNewKeyRequest(characteristicValue: newValue) else {
                return false
            }
            self.createKey = request
            return true
        case (_confirmKey.valueHandle, .single(let newValue)):
            guard let request = ConfirmNewKeyRequest(characteristicValue: newValue) else {
                return false
            }
            self.confirmKey = request
            return true
        default:
            return false
        }
    }
}
#endif
