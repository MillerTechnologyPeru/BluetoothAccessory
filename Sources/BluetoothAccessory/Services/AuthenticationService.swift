//
//  AuthenticationService.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth

/// Accessory Authentication Service
public actor AuthenticationService <Peripheral: AccessoryPeripheralManager> : AccessoryService {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .authentication) }
    
    public let serviceHandle: UInt16
    
    @ManagedWriteOnlyCharacteristic<SetupCharacteristic, Peripheral>
    public var setup: SetupRequest?
    
    @ManagedWriteOnlyCharacteristic<CreateNewKeyCharacteristic, Peripheral>
    public var createKey: CreateNewKeyRequest?
    
    @ManagedWriteOnlyCharacteristic<ConfirmNewKeyCharacteristic, Peripheral>
    public var confirmKey: ConfirmNewKeyRequest?
    
    @ManagedListCharacteristic<KeysCharacteristic, Peripheral>
    public var keys: [KeysCharacteristic.Item]
    
    public init(
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
        _setup = .init(peripheral: peripheral, valueHandle: valueHandles[0])
        _createKey = .init(peripheral: peripheral, valueHandle: valueHandles[1])
        _confirmKey = .init(peripheral: peripheral, valueHandle: valueHandles[2])
        _keys = .init(wrappedValue: keys, peripheral: peripheral, valueHandle: valueHandles[3])
    }
}

public extension AuthenticationService {
    
    var characteristicValues: [ManagedCharacteristicValue] {
        get async {
            [
                $keys
            ]
        }
    }
}
