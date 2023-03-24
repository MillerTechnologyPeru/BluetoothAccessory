//
//  InformationService.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Accessory Information Service
public actor InformationService: AccessoryService {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .information) }
    
    public let serviceHandle: UInt16
    
    @ManagedCharacteristic<IdentifierCharacteristic>
    public var id: UUID
    
    @ManagedCharacteristic<NameCharacteristic>
    public var name: String
    
    @ManagedCharacteristic<AccessoryTypeCharacteristic>
    public var accessoryType: AccessoryType
    
    @ManagedCharacteristic<IdentifyCharacteristic>
    public var identify: Bool
    
    @ManagedCharacteristic<ManufacturerCharacteristic>
    public var manufacturer: String
    
    @ManagedCharacteristic<ModelCharacteristic>
    public var model: String
    
    @ManagedCharacteristic<SerialNumberCharacteristic>
    public var serialNumber: String
    
    @ManagedCharacteristic<SoftwareVersionCharacteristic>
    public var softwareVersion: String
    
    @ManagedListCharacteristic<MetadataCharacteristic>
    public var metadata: [CharacteristicMetadata]
    
    /// Add service to Peripheral and initialize handles.
    public init<Peripheral: AccessoryPeripheralManager>(
        peripheral: Peripheral,
        id: UUID,
        name: String,
        accessoryType: AccessoryType,
        manufacturer: String,
        model: String,
        serialNumber: String,
        softwareVersion: String,
        metadata: [CharacteristicMetadata] = []
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
                MetadataCharacteristic.self
            ]
        )
        self.serviceHandle = serviceHandle
        _id = .init(wrappedValue: id, valueHandle: valueHandles[0])
        _name = .init(wrappedValue: name, valueHandle: valueHandles[1])
        _accessoryType = .init(wrappedValue: accessoryType, valueHandle: valueHandles[2])
        _identify = .init(wrappedValue: false, valueHandle: valueHandles[3])
        _manufacturer = .init(wrappedValue: manufacturer, valueHandle: valueHandles[4])
        _model = .init(wrappedValue: model, valueHandle: valueHandles[5])
        _serialNumber = .init(wrappedValue: serialNumber, valueHandle: valueHandles[6])
        _softwareVersion = .init(wrappedValue: softwareVersion, valueHandle: valueHandles[7])
        _metadata = .init(wrappedValue: metadata, valueHandle: valueHandles[8])
    }
}

public extension InformationService {
    
    var characteristics: [AnyManagedCharacteristic] {
        get async {
            [
                $id,
                $name,
                $accessoryType,
                $identify,
                $manufacturer,
                $model,
                $serialNumber,
                $softwareVersion,
                $metadata
            ]
        }
    }
}
