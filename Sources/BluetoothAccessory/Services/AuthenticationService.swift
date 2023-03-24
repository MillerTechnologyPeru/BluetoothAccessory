//
//  AuthenticationService.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth

/// Accessory Authentication Service
public actor AuthenticationService: AccessoryService {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .authentication) }
    
    public let serviceHandle: UInt16
    
    @ManagedWriteOnlyCharacteristic<SetupCharacteristic>
    public var setup: SetupRequest?
    
    @ManagedWriteOnlyCharacteristic<CreateNewKeyCharacteristic>
    public var createKey: CreateNewKeyRequest?
    
    @ManagedWriteOnlyCharacteristic<ConfirmNewKeyCharacteristic>
    public var confirmKey: ConfirmNewKeyRequest?
    
    @ManagedListCharacteristic<KeysCharacteristic>
    public var keys: [KeysCharacteristic.Item]
    
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        keys: [KeysCharacteristic.Item] = []
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: AuthenticationService.self,
            with: [
                SetupCharacteristic.self,
                CreateNewKeyCharacteristic.self,
                ConfirmNewKeyCharacteristic.self,
                KeysCharacteristic.self
            ]
        )
        self.serviceHandle = serviceHandle
        _setup = .init(valueHandle: valueHandles[0])
        _createKey = .init(valueHandle: valueHandles[1])
        _confirmKey = .init(valueHandle: valueHandles[2])
        _keys = .init(wrappedValue: keys, valueHandle: valueHandles[3])
    }
}

public extension AuthenticationService {
    
    var characteristics: [AnyManagedCharacteristic] {
        get async {
            [
                $setup,
                $createKey,
                $confirmKey,
                $keys
            ]
        }
    }
}
