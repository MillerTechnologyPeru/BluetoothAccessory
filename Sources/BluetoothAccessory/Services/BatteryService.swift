//
//  BatteryService.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

#if canImport(BluetoothGATT)
import Foundation
import Bluetooth

/// Accessory Battery Service
public struct BatteryService: AccessoryService {
        
    public static var type: BluetoothUUID { BluetoothUUID(service: .battery) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<StatusLowBatteryCharacteristic>
    public var statusLowBattery: StatusLowBattery
    
    @ManagedCharacteristic<BatteryLevelCharacteristic>
    public var batteryLevel: UInt8
    
    @ManagedCharacteristic<ChargingStateCharacteristic>
    public var chargingState: ChargingState
    
    /// Add service to Peripheral and initialize handles.
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        statusLowBattery: StatusLowBattery = .normal,
        batteryLevel: UInt8 = 100,
        chargingState: ChargingState = .notCharging
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: OutletService.self,
            with: [
                StatusLowBatteryCharacteristic.self,
                BatteryLevelCharacteristic.self,
                ChargingStateCharacteristic.self
            ]
        )
        self.serviceHandle = serviceHandle
        _statusLowBattery = .init(wrappedValue: statusLowBattery, valueHandle: valueHandles[0])
        _batteryLevel = .init(wrappedValue: batteryLevel, valueHandle: valueHandles[1])
        _chargingState = .init(wrappedValue: chargingState, valueHandle: valueHandles[2])
    }
}

public extension BatteryService {
    
    var characteristics: [AnyManagedCharacteristic] {
        [
            $statusLowBattery,
            $batteryLevel,
            $chargingState
        ]
    }
}
#endif
