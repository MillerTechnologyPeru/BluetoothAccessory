//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 3/1/24.
//


#if canImport(BluetoothGATT)
import Foundation
import Bluetooth
import GATT
import BluetoothAccessory

/// Sensor Accessory Battery Service
public struct SensorBatteryService: AccessoryService {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .battery) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<StatusLowBatteryCharacteristic>
    public var statusLowBattery: StatusLowBattery
    
    @ManagedCharacteristic<BatteryLevelCharacteristic>
    public var batteryLevel: UInt8
    
    @ManagedCharacteristic<ChargingStateCharacteristic>
    public var chargingState: ChargingState
    
    @ManagedCharacteristic<BatteryVoltageCharacteristic>
    public var batteryVoltage: Float
    
    /// Add service to Peripheral and initialize handles.
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        statusLowBattery: StatusLowBattery = .normal,
        batteryLevel: UInt8 = 100,
        chargingState: ChargingState = .notChargeable,
        batteryVoltage: Float = 3.3
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: SensorBatteryService.self,
            with: [
                StatusLowBatteryCharacteristic.self,
                BatteryLevelCharacteristic.self,
                ChargingStateCharacteristic.self,
                BatteryVoltageCharacteristic.self
            ]
        )
        self.serviceHandle = serviceHandle
        _statusLowBattery = .init(wrappedValue: statusLowBattery, valueHandle: valueHandles[0])
        _batteryLevel = .init(wrappedValue: batteryLevel, valueHandle: valueHandles[1])
        _chargingState = .init(wrappedValue: chargingState, valueHandle: valueHandles[2])
        _batteryVoltage = .init(wrappedValue: batteryVoltage, valueHandle: valueHandles[3])
    }
}

public extension SensorBatteryService {
    
    var characteristics: [AnyManagedCharacteristic] {
        [
            $statusLowBattery,
            $batteryLevel,
            $chargingState,
            $batteryVoltage,
        ]
    }
}

#endif
