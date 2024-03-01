//
//  TemperatureSensorService.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

#if canImport(BluetoothGATT)
import Foundation
import Bluetooth

/// Temperature Sensor Service
public struct TemperatureSensorService: AccessoryService {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .temperatureSensor) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<CurrentTemperatureCharacteristic>
    public var currentTemperature: Float
    
    /// Add service to Peripheral and initialize handles.
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        currentTemperature: Float
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: TemperatureSensorService.self,
            with: [
                CurrentTemperatureCharacteristic.self,
            ]
        )
        self.serviceHandle = serviceHandle
        _currentTemperature = .init(wrappedValue: currentTemperature, valueHandle: valueHandles[0])
    }
}

public extension TemperatureSensorService {
    
    var characteristics: [AnyManagedCharacteristic] {
        [
            $currentTemperature
        ]
    }
    
    mutating func update(characteristic valueHandle: UInt16, with newValue: ManagedCharacteristicValue) -> Bool {
        switch (valueHandle, newValue) {
        case (_currentTemperature.valueHandle, .single(.float(let newValue))):
            self.currentTemperature = newValue
            return true
        default:
            return false
        }
    }
}
#endif
