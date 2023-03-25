//
//  OutletService.swift
//  
//
//  Created by Alsey Coleman Miller on 3/24/23.
//

import Foundation
import Bluetooth

/// Accessory Information Service
public struct OutletService: AccessoryService {
        
    public static var type: BluetoothUUID { BluetoothUUID(service: .outlet) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<PowerStateCharacteristic>
    public var powerState: Bool
    
    /// Add service to Peripheral and initialize handles.
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        powerState: Bool = false
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: OutletService.self,
            with: [
                PowerStateCharacteristic.self,
            ]
        )
        self.serviceHandle = serviceHandle
        _powerState = .init(wrappedValue: powerState, valueHandle: valueHandles[0])
    }
}

public extension OutletService {
    
    var characteristics: [AnyManagedCharacteristic] {
        [
            $powerState
        ]
    }
    
    mutating func update(characteristic valueHandle: UInt16, with newValue: ManagedCharacteristicValue) -> Bool {
        switch (valueHandle, newValue) {
        case (_powerState.valueHandle, .single(.bool(let newValue))):
            self.powerState = newValue
            return true
        default:
            return false
        }
    }
}
