//
//  Server.swift
//  
//
//  Created by Alsey Coleman Miller on 3/15/23.
//

import Foundation
import Bluetooth
import GATT

/// Bluetooth Accessory Server
public actor BluetoothAccesoryServer <Peripheral: AccessoryPeripheralManager>: Identifiable {
    
    public let peripheral: Peripheral
    
    public let id: UUID
    
    public let rssi: Int8
    
    public let name: String
    
    public let service: ServiceType
    
    public private(set) var beacon: AccessoryBeacon
    
    public private(set) var characteristics = [UInt16: (service: BluetoothUUID, characteristic: any AccessoryCharacteristic)]()
    
    public init(
        peripheral: Peripheral,
        id: UUID,
        rssi: Int8,
        name: String,
        advertised service: ServiceType,
        services: [BluetoothUUID: [any AccessoryCharacteristic]]
    ) async throws {
        self.peripheral = peripheral
        self.id = id
        self.rssi = rssi
        self.name = name
        self.service = service
        self.beacon = .id(id)
        try await self.start(with: services)
    }
    
    private func start(with services: [BluetoothUUID: [any AccessoryCharacteristic]]) async throws {
        for (serviceUUID, characteristics) in services {
            let characteristicAttributes = characteristics.map {
                GATTAttribute.Characteristic(
                    uuid: type(of: $0).type,
                    value: $0.encode(),
                    permissions: type(of: $0).gattPermissions,
                    properties: type(of: $0).gattProperties,
                    descriptors: type(of: $0).gattDescriptors
                )
            }
            let service = GATTAttribute.Service(
                uuid: serviceUUID,
                primary: true,
                characteristics: characteristicAttributes,
                includedServices: []
            )
            let (_, valueHandles) = try await peripheral.add(service: service)
            for (index, characteristic) in characteristics.enumerated() {
                let handle = valueHandles[index]
                self.characteristics[handle] = (service: serviceUUID, characteristic: characteristic)
            }
        }
        
        try await peripheral.start(
            name: name,
            service: service,
            id: id,
            rssi: rssi
        )
    }
}

