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
    
    public private(set) var characteristicHandles = [UInt16: (service: BluetoothUUID, characteristic: any AccessoryCharacteristic.Type)]()
    
    public init(
        peripheral: Peripheral,
        id: UUID,
        rssi: Int8,
        name: String,
        advertised service: ServiceType,
        services: [AccessoryService.Type]
    ) async throws {
        self.peripheral = peripheral
        self.id = id
        self.rssi = rssi
        self.name = name
        self.service = service
        self.beacon = .id(id)
        try await self.start(with: services)
    }
    
    private func start(with services: [AccessoryService.Type]) async throws {
        for service in services {
            let characteristicAttributes = service.characteristics.map {
                GATTAttribute.Characteristic(
                    uuid: $0.type,
                    value: Data(),
                    permissions: $0.gattPermissions,
                    properties: $0.gattProperties,
                    descriptors: $0.gattDescriptors
                )
            }
            let serviceAttribute = GATTAttribute.Service(
                uuid: service.type,
                primary: service.isPrimary,
                characteristics: characteristicAttributes,
                includedServices: []
            )
            let (_, valueHandles) = try await peripheral.add(service: serviceAttribute)
            for (index, characteristic) in service.characteristics.enumerated() {
                let handle = valueHandles[index]
                characteristicHandles[handle] = (service: serviceAttribute.uuid, characteristic: characteristic)
            }
        }
        
        try await peripheral.start()
        try await advertise(beacon: beacon)
    }
    
    private func advertise(beacon: AccessoryBeacon) async throws {
        try await peripheral.advertise(
            beacon: beacon,
            rssi: rssi,
            name: name,
            service: service
        )
        self.beacon = beacon
    }
    
    func willRead(_ request: GATTReadRequest<Peripheral.Central>) async -> ATTError? {
        guard let _ = characteristicHandles[request.handle] else {
            return .readNotPermitted
        }
        //log?("")
        return nil
    }
    
    func willWrite(_ request: GATTWriteRequest<Peripheral.Central>) async -> ATTError? {
        guard let _ = characteristicHandles[request.handle] else {
            return .writeNotPermitted
        }
        return nil
    }
    
    func didWrite(_ request: GATTWriteConfirmation<Peripheral.Central>) async {
        
    }
}
