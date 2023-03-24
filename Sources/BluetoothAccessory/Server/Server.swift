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
    
    weak var delegate: BluetoothAccessoryServerDelegate?
    
    deinit {
        peripheral.willRead = nil
        peripheral.willWrite = nil
        peripheral.didWrite = nil
    }
    
    public init(
        peripheral: Peripheral,
        delegate: BluetoothAccessoryServerDelegate? = nil,
        id: UUID,
        rssi: Int8,
        name: String,
        advertised service: ServiceType,
        services: [any AccessoryService]
    ) async throws {
        self.peripheral = peripheral
        self.delegate = delegate
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
        delegate?.didAdvertise(beacon: beacon)
    }
    
    private func willRead(_ request: GATTReadRequest<Peripheral.Central>) async -> ATTError? {
        delegate?.log("Will read characteristic \(request.uuid)")
        return nil
    }
    
    private func willWrite(_ request: GATTWriteRequest<Peripheral.Central>) async -> ATTError? {
        delegate?.log("Will write characteristic \(request.uuid)")
        // find matching characteristic
        guard let (service, characteristic) = await characteristic(for: request.handle) else {
            delegate?.log("Cannot write unknown characteristic \(request.uuid)")
            return .writeNotPermitted
        }
        guard characteristic.properties.contains(.write) else {
            delegate?.log("Characteristic \(request.uuid) is not writable")
            return .writeNotPermitted
        }
        // list write
        if characteristic.properties.contains(.list) {
            // TODO: List write
            return .writeNotPermitted
        } else if characteristic.properties.contains(.encrypted) {
            guard let delegate = delegate else {
                delegate?.log("Cannot handle encrypted write for \(request.uuid)")
                return .unlikelyError
            }
            // encrypted write
            guard let encryptedData = EncryptedData(data: request.newValue) else {
                delegate.log("Unable to decode encrypted write for \(request.uuid)")
                return .writeNotPermitted
            }
            let keyID = encryptedData.authentication.message.id
            let secret: KeyData
            if keyID == .zero, request.uuid == BluetoothUUID(characteristic: .setup) {
                secret = delegate.setupSharedSecret
            } else {
                guard let secretData = await delegate.key(for: keyID) else {
                    delegate.log("Rejected encrypted write for \(request.uuid) with unknown key \(keyID)")
                    return .writeNotPermitted
                }
                secret = secretData
            }
            guard let decryptedData = try? encryptedData.decrypt(using: secret) else {
                delegate.log("Unable to decrypt write request for \(request.uuid)")
                return .writeNotPermitted
            }
            guard let value = CharacteristicValue(from: decryptedData, format: characteristic.format) else {
                delegate.log("Unable to decode write request for \(request.uuid) as \(characteristic.format)")
                return .writeNotPermitted
            }
            guard await service.update(characteristic: characteristic, with: .single(value)) else {
                delegate.log("Unable to decode write request for \(request.uuid)")
                return .writeNotPermitted
            }
            return nil
        } else {
            // simple write
            guard let value = CharacteristicValue(from: request.newValue, format: characteristic.format) else {
                delegate?.log("Unable to decode write request for \(request.uuid)")
                return .writeNotPermitted
            }
            guard await service.update(characteristic: characteristic, with: .single(value)) else {
                delegate?.log("Unable to decode write request for \(request.uuid)")
                return .writeNotPermitted
            }
            return nil
        }
    }
    
    private func didWrite(_ request: GATTWriteConfirmation<Peripheral.Central>) async {
        delegate?.log("Did write characteristic \(request.uuid)")
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
    
    private func characteristic(for handle: UInt16) async -> (any AccessoryService, AnyManagedCharacteristic)? {
        for service in services {
            for characteristic in await service.characteristics {
                guard characteristic.handle == handle else {
                    continue
                }
                return (service, characteristic)
            }
        }
        return nil
    }
}

public protocol BluetoothAccessoryServerDelegate: AnyObject {
    
    func log(_ message: String)
    
    func didAdvertise(beacon: AccessoryBeacon)
    
    /// Return key for the specified ID or shared secret.
    func key(for id: UUID) async -> KeyData?
    
    var setupSharedSecret: KeyData { get }
}
