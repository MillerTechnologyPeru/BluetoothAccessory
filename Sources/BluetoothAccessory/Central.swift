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
