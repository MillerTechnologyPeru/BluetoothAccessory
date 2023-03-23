//
//  InformationService.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Accessory Information Service
public actor InformationService <Peripheral: AccessoryPeripheralManager> : AccessoryService {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .information) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<IdentifierCharacteristic, Peripheral>
    public var id: UUID
    
    @ManagedCharacteristic<NameCharacteristic, Peripheral>
    public var name: String
    
    @ManagedCharacteristic<AccessoryTypeCharacteristic, Peripheral>
    public var accessoryType: AccessoryType
    
    @ManagedCharacteristic<IdentifyCharacteristic, Peripheral>
    public var identify: Bool
    
    @ManagedCharacteristic<ManufacturerCharacteristic, Peripheral>
    public var manufacturer: String
    
    @ManagedCharacteristic<ModelCharacteristic, Peripheral>
    public var model: String
    
    @ManagedCharacteristic<SerialNumberCharacteristic, Peripheral>
    public var serialNumber: String
    
    @ManagedCharacteristic<SoftwareVersionCharacteristic, Peripheral>
    public var softwareVersion: String
    
    public init(
        peripheral: Peripheral,
        id: UUID,
        name: String,
        accessoryType: AccessoryType,
        manufacturer: String,
        model: String,
        serialNumber: String,
        softwareVersion: String
    ) async throws {
        let (serviceHandle, valueHandles) = try await peripheral.add(
            service: InformationService.self,
            with: [
                IdentifierCharacteristic.self,
                NameCharacteristic.self,
                AccessoryTypeCharacteristic.self,
                IdentifyCharacteristic.self,
                ManufacturerCharacteristic.self,
                ModelCharacteristic.self,
                SerialNumberCharacteristic.self,
                SoftwareVersionCharacteristic.self,
            ]
        )
        self.serviceHandle = serviceHandle
        _id = await .init(wrappedValue: id, peripheral: peripheral, valueHandle: valueHandles[0])
        _name = await .init(wrappedValue: name, peripheral: peripheral, valueHandle: valueHandles[1])
        _accessoryType = await .init(wrappedValue: accessoryType, peripheral: peripheral, valueHandle: valueHandles[2])
        _identify = await .init(wrappedValue: false, peripheral: peripheral, valueHandle: valueHandles[3])
        _manufacturer = await .init(wrappedValue: manufacturer, peripheral: peripheral, valueHandle: valueHandles[4])
        _model = await .init(wrappedValue: model, peripheral: peripheral, valueHandle: valueHandles[5])
        _serialNumber = await .init(wrappedValue: serialNumber, peripheral: peripheral, valueHandle: valueHandles[6])
        _softwareVersion = await .init(wrappedValue: softwareVersion, peripheral: peripheral, valueHandle: valueHandles[7])
    }
}

public extension InformationService {
    
    var characteristicValues: [ManagedCharacteristicValue] {
        get async {
            [
                $id
            ]
        }
    }
}
