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
    
    @ManagedCharacteristic<SetupCharacteristic, Peripheral>
    public var setup: SetupRequest
    
    public init(
        peripheral: Peripheral
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: AuthenticationService.self,
            with: [
                SetupCharacteristic.self,
            ]
        )
        self.serviceHandle = serviceHandle
        _setup = await .init(wrappedValue: SetupRequest(id: .zero, secret: .init()), peripheral: peripheral, valueHandle: valueHandles[0])
    }
}

public extension AuthenticationService {
    
    var characteristicValues: [ManagedCharacteristicValue] {
        get async {
            []
        }
    }
}
