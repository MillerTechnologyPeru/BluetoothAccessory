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
public actor BluetoothAccessoryServer <Peripheral: AccessoryPeripheralManager>: Identifiable {
    
    // MARK: - Properties
    
    public let peripheral: Peripheral
    
    public let id: UUID
    
    public let rssi: Int8
    
    public let name: String
    
    public let advertisedService: ServiceType
    
    public private(set) var beacon: AccessoryBeacon
    
    var services: [any AccessoryService]
    
    weak var delegate: BluetoothAccessoryServerDelegate?
    
    // MARK: - Initialization
    
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
    
    // MARK: - Methods
    
    public subscript <T: AccessoryService> (service: T.Type) -> T {
        get {
            for service in services {
                guard let matchingService = service as? T else {
                    continue
                }
                return matchingService
            }
            fatalError("Invalid service \(service)")
        }
        set {
            guard let index = services.firstIndex(where: { $0 is T }) else {
                fatalError("Invalid service \(service)")
            }
            services[index] = newValue
        }
    }
    
    public func update <T: AccessoryService> (
        _ service: T.Type,
        _ block: (inout T) -> ()
    ) async {
        // update value
        let oldValue = self[service]
        var newValue = oldValue
        block(&newValue)
        self[service] = newValue
        // update DB
        await didModifyService(oldValue: oldValue, newValue: newValue)
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
        delegate?.log("Will read characteristic \(request.uuid.bluetoothAccessoryDescription)")
        return nil
    }
    
    private func willWrite(_ request: GATTWriteRequest<Peripheral.Central>) async -> ATTError? {
        delegate?.log("Will write characteristic \(request.uuid.bluetoothAccessoryDescription)")
        // find matching characteristic
        guard let (serviceIndex, characteristic) = self.characteristic(for: request.handle) else {
            return nil // could be descriptor write
        }
        guard characteristic.properties.contains(.write) else {
            delegate?.log("Characteristic \(request.uuid.bluetoothAccessoryDescription) is not writable")
            return .writeNotPermitted
        }
        // list write
        if characteristic.properties.contains(.list) {
            // TODO: List write
            assertionFailure("Not implemented")
            return .unlikelyError
        } else if characteristic.properties.contains(.encrypted) {
            guard let delegate = delegate else {
                delegate?.log("Cannot handle encrypted write for \(request.uuid.bluetoothAccessoryDescription)")
                return .unlikelyError
            }
            // encrypted write
            guard let encryptedData = EncryptedData(data: request.newValue) else {
                delegate.log("Unable to decode encrypted write for \(request.uuid.bluetoothAccessoryDescription)")
                return .writeNotPermitted
            }
            let keyID = encryptedData.authentication.message.id
            let secret: KeyData
            if keyID == .zero, request.uuid == BluetoothUUID(characteristic: .setup) {
                secret = await delegate.setupSharedSecret
            } else {
                guard let secretData = await delegate.key(for: keyID) else {
                    delegate.log("Rejected encrypted write for \(request.uuid.bluetoothAccessoryDescription) with unknown key \(keyID)")
                    return .writeNotPermitted
                }
                secret = secretData
            }
            // verify crypto hash
            let cryptoHash = await delegate.cryptoHash
            guard encryptedData.authentication.message.nonce == cryptoHash else {
                delegate.log("Write request for \(request.uuid.bluetoothAccessoryDescription) authenticated with expired nonce")
                return .writeNotPermitted
            }
            // decrypt
            guard let decryptedData = try? encryptedData.decrypt(using: secret) else {
                delegate.log("Unable to decrypt write request for \(request.uuid.bluetoothAccessoryDescription)")
                return .writeNotPermitted
            }
            guard let value = CharacteristicValue(from: decryptedData, format: characteristic.format) else {
                delegate.log("Unable to decode write request for \(request.uuid.bluetoothAccessoryDescription) as \(characteristic.format)")
                return .writeNotPermitted
            }
            guard services[serviceIndex].update(characteristic: request.handle, with: .single(value)) else {
                delegate.log("Unable to decode write request for \(request.uuid.bluetoothAccessoryDescription)")
                return .writeNotPermitted
            }
            return nil
        } else {
            // simple write
            guard let value = CharacteristicValue(from: request.newValue, format: characteristic.format) else {
                delegate?.log("Unable to decode write request for \(request.uuid.bluetoothAccessoryDescription)")
                return .writeNotPermitted
            }
            guard services[serviceIndex].update(characteristic: request.handle, with: .single(value)) else {
                delegate?.log("Unable to decode write request for \(request.uuid.bluetoothAccessoryDescription)")
                return .writeNotPermitted
            }
            return nil
        }
    }
    
    private func didWrite(_ request: GATTWriteConfirmation<Peripheral.Central>) async {
        delegate?.log("Did write characteristic \(request.uuid.bluetoothAccessoryDescription)")
        // notify delegate
        await delegate?.updateCryptoHash()
        await delegate?.didWrite(request.handle)
    }
    
    /// Update unencrypted readable values.
    private func updateValues() async {
        for service in services {
            for characteristic in service.characteristics {
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
    
    public func didModifyService <T: AccessoryService> (
        oldValue: T,
        newValue: T
    ) async {
        // update DB
        let oldCharacteristics = oldValue.characteristics
        for newCharacteristic in newValue.characteristics {
            // did change
            guard let oldCharacteristic = oldCharacteristics.first(where: { $0.handle == newCharacteristic.handle }),
                  oldCharacteristic.value != newCharacteristic.value else {
                continue
            }
            // unencrypted value
            if newCharacteristic.properties.contains(.read),
               newCharacteristic.properties.contains(.encrypted) == false,
               newCharacteristic.properties.contains(.list) == false,
               case let .single(value) = newCharacteristic.value {
                // update DB
                await peripheral.write(value.encode(), forCharacteristic: newCharacteristic.handle)
            }
            // write only
            if newCharacteristic.properties.contains(.write),
               newCharacteristic.properties.contains(.list) == false,
               case .none = newCharacteristic.value {
                // update DB
                await peripheral.write(Data(), forCharacteristic: newCharacteristic.handle)
            }
        }
    }
    
    private func characteristic(for handle: UInt16) -> (serviceIndex: Int, characteristic: AnyManagedCharacteristic)? {
        for (serviceIndex, service) in services.enumerated() {
            for characteristic in service.characteristics {
                guard characteristic.handle == handle else {
                    continue
                }
                return (serviceIndex, characteristic)
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
    
    var setupSharedSecret: KeyData { get async }
    
    func didWrite(_ handle: UInt16) async
    
    var cryptoHash: Nonce { get async }
    
    func updateCryptoHash() async
}
