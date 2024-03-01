//
//  HumiditySensorService.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

#if canImport(BluetoothGATT)
import Foundation
import Bluetooth

/// Humidity Sensor Service
public struct HumiditySensorService: AccessoryService {
        
    public static var type: BluetoothUUID { BluetoothUUID(service: .humiditySensor) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<CurrentRelativeHumidityCharacteristic>
    public var currentRelativeHumidity: Float
    
    /// Add service to Peripheral and initialize handles.
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        currentRelativeHumidity: Float
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: HumiditySensorService.self,
            with: [
                CurrentRelativeHumidityCharacteristic.self,
            ]
        )
        self.serviceHandle = serviceHandle
        _currentRelativeHumidity = .init(wrappedValue: currentRelativeHumidity, valueHandle: valueHandles[0])
    }
}

public extension HumiditySensorService {
    
    var characteristics: [AnyManagedCharacteristic] {
        [
            $currentRelativeHumidity
        ]
    }
    
    mutating func update(characteristic valueHandle: UInt16, with newValue: ManagedCharacteristicValue) -> Bool {
        switch (valueHandle, newValue) {
        case (_currentRelativeHumidity.valueHandle, .single(.float(let newValue))):
            self.currentRelativeHumidity = newValue
            return true
        default:
            return false
        }
    }
}
#endif
