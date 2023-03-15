//
//  Central.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public extension CentralManager {
    
    func connection<T>(
        for peripheral: Peripheral,
        _ connection: (GATTConnection<Self>) async throws -> (T)
    ) async throws -> T {
        // connect first
        try await self.connect(to: peripheral)
        do {
            // cache MTU
            let maximumTransmissionUnit = try await self.maximumTransmissionUnit(for: peripheral)
            // get characteristics by UUID
            let servicesCache = try await self.cacheServices(for: peripheral)
            let connectionCache = GATTConnection(
                central: self,
                peripheral: peripheral,
                maximumTransmissionUnit: maximumTransmissionUnit,
                cache: servicesCache
            )
            // perform action
            let value = try await connection(connectionCache)
            // disconnect
            await self.disconnect(peripheral)
            return value
        }
        catch {
            await self.disconnect(peripheral)
            throw error
        }
    }
}

public struct GATTConnection <Central: CentralManager> {
    
    internal unowned let central: Central
    
    public let peripheral: Central.Peripheral
    
    public let maximumTransmissionUnit: GATT.MaximumTransmissionUnit
    
    public let cache: Cache
}

public extension GATTConnection {
    
    var maximumUpdateValueLength: Int {
        Int(maximumTransmissionUnit.rawValue) - 3
    }
}

public extension GATTConnection {
    
    struct Cache: Equatable, Hashable {
        
        public var services: [ServiceCache]
        
        public init(services: [ServiceCache] = []) {
            self.services = services
        }
    }
    
    struct ServiceCache: Equatable, Hashable, Identifiable {
        
        public var id: BluetoothUUID {
            service.uuid
        }
        
        public let service: GATT.Service<Central.Peripheral, Central.AttributeID>
        
        public var characteristics: [CharacteristicCache]
    }
    
    struct CharacteristicCache: Equatable, Hashable, Identifiable {
        
        public var id: BluetoothUUID {
            characteristic.uuid
        }
        
        public let characteristic: GATT.Characteristic<Central.Peripheral, Central.AttributeID>
        
        public var descriptors: [GATT.Descriptor<Central.Peripheral, Central.AttributeID>]
    }
}

internal extension CentralManager {
    
    /// Fetch all characteristics for all services.
    func cacheServices(
        for peripheral: Peripheral
    ) async throws -> GATTConnection<Self>.Cache {
        var cache = GATTConnection<Self>.Cache()
        let foundServices = try await discoverServices([], for: peripheral)
        for service in foundServices {
            var serviceCache = GATTConnection<Self>.ServiceCache(service: service, characteristics: [])
            let foundCharacteristics = try await discoverCharacteristics([], for: service)
            for characteristic in foundCharacteristics {
                var characteristicCache = GATTConnection<Self>.CharacteristicCache(characteristic: characteristic, descriptors: [])
                characteristicCache.descriptors = try await discoverDescriptors(for: characteristic)
                serviceCache.characteristics.append(characteristicCache)
            }
            cache.services.append(serviceCache)
        }
        return cache
    }
}

public extension GATTConnection {
    
    /// Write an unencrypted characteristic.
    func write(
        _ value: Data,
        for characteristic: Characteristic<Central.Peripheral, Central.AttributeID>
    ) async throws {
        assert(characteristic.properties.contains(.write), "Characteristic does not support write")
        let withResponse = characteristic.properties.contains(.writeWithoutResponse) ? false : true
        try await self.central.writeValue(value, for: characteristic, withResponse: withResponse)
    }
    
    /// Write an encrypted characteristic.
    func writeEncrypted(
        _ value: Data,
        for characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        key: Credential,
        log: ((String) -> ())? = nil
    ) async throws {
        assert(characteristic.properties.contains(.write), "Characteristic does not support write")
        let withResponse = characteristic.properties.contains(.writeWithoutResponse) ? false : true
        let encrypted = try EncryptedData(encrypt: value, using: key.secret, id: key.id)
        let chunks = Chunk.from(encrypted.data, maximumUpdateValueLength: maximumUpdateValueLength)
        for (index, chunk) in chunks.enumerated() {
            log?("Sent chunk \(index + 1) (\(chunks.length)/\(chunk.total)) for \(characteristic.uuid)")
            try await self.central.writeValue(chunk.data, for: characteristic, withResponse: withResponse)
        }
    }
    
    /// Read a characteristic.
    func read(
        characteristic: Characteristic<Central.Peripheral, Central.AttributeID>
    ) async throws -> Data {
        assert(characteristic.properties.contains(.read), "Characteristic does not support reading")
        let data = try await self.central.readValue(for: characteristic)
        return data
    }
    
    /// Read an encrypted characteristic.
    func readEncryped(
        characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        key: Credential,
        log: ((String) -> ())? = nil
    ) async throws -> Data {
        assert(characteristic.properties.contains(.notify), "Characteristic does not support notifications")
        let stream = try await self.central.notify(for: characteristic)
        var chunks = [Chunk]()
        chunks.reserveCapacity(2)
        for try await notification in stream {
            guard let chunk = Chunk(data: notification) else {
                throw BluetoothAccessoryError.invalidData(notification)
            }
            chunks.append(chunk)
            log?("Received chunk \(chunks.count) (\(chunks.length)/\(chunk.total)) for \(characteristic.uuid)")
            assert(chunks.isEmpty == false)
            guard chunks.length >= chunk.total else {
                continue // wait for more chunks
            }
            stream.stop()
        }
        let data = Data(chunks: chunks)
        guard let encryptedData = EncryptedData(data: data) else {
            throw BluetoothAccessoryError.invalidData(data)
        }
        let decrypted = try encryptedData.decrypt(using: key.secret)
        return decrypted
    }
    
    /// Read list characteristic.
    func readList(
        notify notifyCharacteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        write writeCharacteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        writeValue: @autoclosure () throws -> (Data),
        key: Credential,
        log: ((String) -> ())? = nil
    ) async throws -> AsyncThrowingStream<Data, Error> {
        let stream = try await self.central.notify(for: notifyCharacteristic)
        try await self.writeEncrypted(writeValue(), for: writeCharacteristic, key: key)
        return AsyncThrowingStream(Data.self, bufferingPolicy: .unbounded) { continuation in
            Task.detached {
                do {
                    var notificationsCount = 0
                    var chunks = [Chunk]()
                    chunks.reserveCapacity(2)
                    for try await chunkNotification in stream {
                        guard let chunk = Chunk(data: chunkNotification) else {
                            throw BluetoothAccessoryError.invalidData(chunkNotification)
                        }
                        chunks.append(chunk)
                        log?("Received chunk \(chunks.count) (\(chunks.length)/\(chunk.total)) for \(notifyCharacteristic.uuid)")
                        assert(chunks.isEmpty == false)
                        guard chunks.length >= chunk.total else {
                            continue // wait for more chunks
                        }
                        guard let notification = EncryptedNotification(chunks: chunks) else {
                            throw BluetoothAccessoryError.invalidData(Data(chunks: chunks))
                        }
                        let decryptedValue = try notification.value.decrypt(using: key.secret)
                        continuation.yield(decryptedValue)
                        notificationsCount += 1
                        log?("Received\(notification.isLast ? " last" : "") notification \(notificationsCount) for \(notifyCharacteristic.uuid)")
                        chunks.removeAll(keepingCapacity: true)
                        guard notification.isLast else {
                            continue // wait for final value
                        }
                        stream.stop()
                    }
                    continuation.finish()
                } catch {
                    stream.stop()
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

public extension GATTConnection {
    
    /// Write an unencrypted characteristic.
    func write(
        _ value: CharacteristicValue,
        for characteristic: Characteristic<Central.Peripheral, Central.AttributeID>
    ) async throws {
        try await write(value.encode(), for: characteristic)
    }
    
    /// Write an encrypted characteristic.
    func writeEncrypted(
        _ value: CharacteristicValue,
        for characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        key: Credential
    ) async throws {
        try await writeEncrypted(value.encode(), for: characteristic, key: key)
    }
    
    /// Read a characteristic.
    func read(
        characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        format: CharacteristicFormat
    ) async throws -> CharacteristicValue {
        let data = try await read(characteristic: characteristic)
        guard let value = CharacteristicValue(from: data, format: format) else {
            throw BluetoothAccessoryError.invalidCharacteristicValue(characteristic.uuid)
        }
        return value
    }
    
    /// Read an encrypted characteristic.
    func readEncryped(
        characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        format: CharacteristicFormat,
        key: Credential
    ) async throws -> CharacteristicValue {
        let data = try await readEncryped(characteristic: characteristic, key: key)
        guard let value = CharacteristicValue(from: data, format: format) else {
            throw BluetoothAccessoryError.invalidCharacteristicValue(characteristic.uuid)
        }
        return value
    }
    
    /// Read list characteristic
    func readList(
        notify notifyCharacteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        write writeCharacteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        writeValue: @autoclosure () throws -> (CharacteristicValue),
        format: CharacteristicFormat,
        key: Credential,
        log: ((String) -> ())? = nil
    ) async throws -> AsyncThrowingMapSequence<AsyncThrowingStream<Data, Error>, CharacteristicValue> {
        let stream = try await readList(notify: notifyCharacteristic, write: writeCharacteristic, writeValue: writeValue().encode(), key: key, log: log)
        let mapped = stream.map {
            guard let value = CharacteristicValue(from: $0, format: format) else {
                throw BluetoothAccessoryError.invalidData($0)
            }
            return value
        }
        return mapped
    }
}


public extension GATTConnection {
    
    /// Write an unencrypted characteristic.
    func write<T: AccessoryCharacteristic>(
        _ value: T,
        for characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        withResponse: Bool = true
    ) async throws {
        try await write(value.encode(), for: characteristic)
    }
    
    /// Write an encrypted characteristic.
    func writeEncrypted<T: AccessoryCharacteristic>(
        _ value: T,
        for characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        withResponse: Bool = true,
        key: Credential
    ) async throws {
        try await writeEncrypted(value.encode(), for: characteristic, key: key)
    }
    
    /// Read a characteristic.
    func read<T: AccessoryCharacteristic>(
        _ type: T.Type,
        characteristic: Characteristic<Central.Peripheral, Central.AttributeID>
    ) async throws -> T {
        let data = try await read(characteristic: characteristic)
        guard let value = T.init(from: data) else {
            throw BluetoothAccessoryError.invalidCharacteristicValue(characteristic.uuid)
        }
        return value
    }
    
    /// Read an encrypted characteristic.
    func readEncryped<T: AccessoryCharacteristic>(
        _ type: T.Type,
        characteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        key: Credential
    ) async throws -> T {
        let data = try await readEncryped(characteristic: characteristic, key: key)
        guard let value = T.init(from: data) else {
            throw BluetoothAccessoryError.invalidCharacteristicValue(characteristic.uuid)
        }
        return value
    }
    
    /// Read list characteristic
    func readList<Notification: AccessoryCharacteristic, Write: AccessoryCharacteristic>(
        notify notifyCharacteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        write writeCharacteristic: Characteristic<Central.Peripheral, Central.AttributeID>,
        writeValue: @autoclosure () throws -> (Write),
        key: Credential,
        log: ((String) -> ())? = nil
    ) async throws -> AsyncThrowingMapSequence<AsyncThrowingStream<Data, Error>, Notification> {
        let stream = try await readList(notify: notifyCharacteristic, write: writeCharacteristic, writeValue: writeValue().encode(), key: key, log: log)
        let mapped = stream.map {
            guard let value = Notification.init(from: $0) else {
                throw BluetoothAccessoryError.invalidData($0)
            }
            return value
        }
        return mapped
    }
}
