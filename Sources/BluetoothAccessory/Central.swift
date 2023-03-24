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

public extension GATTConnection.Cache {
    
    func characteristic(_ uuid: BluetoothUUID, service: BluetoothUUID) throws -> GATT.Characteristic<Central.Peripheral, Central.AttributeID> {
        guard let service = services.first(where: { $0.id == service })
            else { throw BluetoothAccessoryError.serviceNotFound(service) }
        guard let characteristic = service.characteristics.first(where: { $0.id == uuid })
            else { throw BluetoothAccessoryError.characteristicNotFound(uuid) }
        return characteristic.characteristic
    }
    
    func characteristic(_ type: CharacteristicType, service: ServiceType) throws -> GATT.Characteristic<Central.Peripheral, Central.AttributeID> {
        try self.characteristic(BluetoothUUID(characteristic: type), service: BluetoothUUID(service: service))
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
                // FIXME: Fix descriptor discovery on Linux
                #if os(iOS)
                characteristicCache.descriptors = try await discoverDescriptors(for: characteristic)
                #endif
                serviceCache.characteristics.append(characteristicCache)
            }
            cache.services.append(serviceCache)
        }
        return cache
    }
}

public extension CentralManager {
    
    /// Write an unencrypted characteristic.
    func write(
        _ value: Data,
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws {
        assert(characteristic.properties.contains(.write), "Characteristic does not support write")
        let withResponse = characteristic.properties.contains(.writeWithoutResponse) ? false : true
        try await self.writeValue(value, for: characteristic, withResponse: withResponse)
    }
    
    /// Write an encrypted characteristic.
    func writeEncrypted(
        _ value: Data,
        for characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws {
        assert(characteristic.properties.contains(.write), "Characteristic does not support write")
        let withResponse = characteristic.properties.contains(.writeWithoutResponse) ? false : true
        let cryptoHash = try await self.read(CryptoHashCharacteristic.self, characteristic: cryptoHashCharacteristic)
        let encrypted = try EncryptedData(encrypt: value, using: key.secret, id: key.id, nonce: cryptoHash.value)
        try await self.writeValue(encrypted.data, for: characteristic, withResponse: withResponse)
    }
    
    /// Read a characteristic.
    func read(
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> Data {
        assert(characteristic.properties.contains(.read), "Characteristic does not support reading")
        return try await self.readValue(for: characteristic)
    }
    
    /// Read an encrypted characteristic.
    func readEncryped(
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> Data {
        assert(characteristic.properties.contains(.read), "Characteristic does not support reading")
        // authenticate for encrypted read
        try await authenticate(
            characteristic: characteristic.uuid,
            service: service,
            authenticationCharacteristic: authenticationCharacteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: key
        )
        // read encrypted data
        let data = try await self.readValue(for: characteristic)
        guard let encryptedData = EncryptedData(data: data) else {
            throw BluetoothAccessoryError.invalidData(data)
        }
        return try encryptedData.decrypt(using: key.secret)
    }
    
    /// Read list characteristic.
    func readList(
        characteristic notifyCharacteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> AsyncThrowingStream<Data, Error> {
        let log = self.log
        // authenticate for encrypted read
        try await authenticate(
            characteristic: notifyCharacteristic.uuid,
            service: service,
            authenticationCharacteristic: authenticationCharacteristic,
            cryptoHash: cryptoHashCharacteristic,
            key: key
        )
        // enable notifications
        let stream = try await self.notify(for: notifyCharacteristic)
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

public extension CentralManager {
    
    /// Write an unencrypted characteristic.
    func write(
        _ value: CharacteristicValue,
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws {
        try await write(value.encode(), for: characteristic)
    }
    
    /// Write an encrypted characteristic.
    func writeEncrypted(
        _ value: CharacteristicValue,
        for characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws {
        try await writeEncrypted(value.encode(), for: characteristic, cryptoHash: cryptoHashCharacteristic, key: key)
    }
    
    /// Read a characteristic.
    func read(
        characteristic: Characteristic<Peripheral, AttributeID>,
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
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential,
        format: CharacteristicFormat
    ) async throws -> CharacteristicValue {
        let data = try await readEncryped(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        )
        guard let value = CharacteristicValue(from: data, format: format) else {
            throw BluetoothAccessoryError.invalidCharacteristicValue(characteristic.uuid)
        }
        return value
    }
    
    /// Read list characteristic
    func readList(
        characteristic notifyCharacteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential,
        format: CharacteristicFormat
    ) async throws -> AsyncThrowingMapSequence<AsyncThrowingStream<Data, Error>, CharacteristicValue> {
        let stream = try await readList(
            characteristic: notifyCharacteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        )
        let mapped = stream.map {
            guard let value = CharacteristicValue(from: $0, format: format) else {
                throw BluetoothAccessoryError.invalidData($0)
            }
            return value
        }
        return mapped
    }
}

public extension CentralManager {
    
    /// Write an unencrypted characteristic.
    func write<T: AccessoryCharacteristic>(
        _ value: T,
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws {
        assert(T.properties.contains(.write))
        assert(T.properties.contains(.encrypted) == false)
        try await write(value.encode(), for: characteristic)
    }
    
    /// Write an encrypted characteristic.
    func writeEncrypted<T: AccessoryCharacteristic>(
        _ value: T,
        for characteristic: Characteristic<Peripheral, AttributeID>,
        cryptoHash: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws {
        assert(T.properties.contains(.write))
        assert(T.properties.contains(.encrypted))
        try await writeEncrypted(value.encode(), for: characteristic, cryptoHash: cryptoHash, key: key)
    }
    
    /// Read a characteristic.
    func read<T: AccessoryCharacteristic>(
        _ type: T.Type,
        characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> T {
        assert(type.properties.contains(.read))
        assert(type.properties.contains(.encrypted) == false)
        let data = try await read(characteristic: characteristic)
        guard let value = T.init(from: data) else {
            throw BluetoothAccessoryError.invalidCharacteristicValue(characteristic.uuid)
        }
        return value
    }
    
    /// Read an encrypted characteristic.
    func readEncryped<T: AccessoryCharacteristic>(
        _ type: T.Type,
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> T {
        assert(type.properties.contains(.read))
        assert(type.properties.contains(.encrypted))
        let data = try await readEncryped(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        )
        guard let value = T.init(from: data) else {
            throw BluetoothAccessoryError.invalidCharacteristicValue(characteristic.uuid)
        }
        return value
    }
    
    /// Read list characteristic
    func readList<Notification: AccessoryCharacteristic>(
        characteristic notifyCharacteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> AsyncThrowingMapSequence<AsyncThrowingStream<Data, Error>, Notification> {
        let stream = try await readList(
            characteristic: notifyCharacteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        )
        let mapped = stream.map {
            guard let value = Notification.init(from: $0) else {
                throw BluetoothAccessoryError.invalidData($0)
            }
            return value
        }
        return mapped
    }
}
