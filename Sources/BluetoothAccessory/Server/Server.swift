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
    
    public let advertisedService: ServiceType
    
    public private(set) var beacon: AccessoryBeacon
    
    public let services: [any AccessoryService]
    
    deinit {
        peripheral.willRead = nil
        peripheral.willWrite = nil
        peripheral.didWrite = nil
    }
    
    public init(
        peripheral: Peripheral,
        id: UUID,
        rssi: Int8,
        name: String,
        advertised service: ServiceType,
        services: [any AccessoryService]
    ) async throws {
        self.peripheral = peripheral
        self.id = id
        self.rssi = rssi
        self.name = name
        self.advertisedService = service
        self.services = services
        self.beacon = .id(id)
        self.setPeripheralCallbacks()
        await self.updateValues()
        try await self.start()
    }
    
    private func setPeripheralCallbacks() {
        // set callbacks
        self.peripheral.willRead = { [unowned self] in
            return await self.willRead($0)
        }
        self.peripheral.willWrite = { [unowned self] in
            return await self.willWrite($0)
        }
        self.peripheral.didWrite = { [unowned self] (confirmation) in
            await self.didWrite(confirmation)
        }
    }
    
    private func start() async throws {
        try await peripheral.start()
        try await advertise(beacon: beacon)
    }
    
    private func advertise(beacon: AccessoryBeacon) async throws {
        try await peripheral.advertise(
            beacon: beacon,
            rssi: rssi,
            name: name,
            service: advertisedService
        )
        self.beacon = beacon
    }
    
    private func willRead(_ request: GATTReadRequest<Peripheral.Central>) async -> ATTError? {
        
        return nil
    }
    
    private func willWrite(_ request: GATTWriteRequest<Peripheral.Central>) async -> ATTError? {
        
        return nil
    }
    
    private func didWrite(_ request: GATTWriteConfirmation<Peripheral.Central>) async {
        
    }
    
    /// Update unencrypted readable values.
    private func updateValues() async {
        for service in services {
            let characteristics = await service.characteristics
            for characteristic in characteristics {
                guard characteristic.properties.contains(.read),
                    characteristic.properties.contains(.encrypted) == false,
                    characteristic.properties.contains(.list) == false,
                    case let .single(value) = characteristic.value
                    else { continue }
                // update DB
                await peripheral.write(value.encode(), forCharacteristic: characteristic.handle)
            }
        }
    }
}
