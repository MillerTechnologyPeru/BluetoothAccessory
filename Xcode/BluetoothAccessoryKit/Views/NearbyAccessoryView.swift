//
//  NearbyAccessoryView.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import DarwinGATT
import BluetoothAccessory

public struct NearbyAccessoryView: View {
    
    @EnvironmentObject
    var store: AccessoryManager
    
    let peripheral: AccessoryManager.Peripheral
    
    let scanResponse: AccessoryScanResponse
    
    public init(
        peripheral: AccessoryManager.Peripheral,
        scanResponse: AccessoryScanResponse
    ) {
        self.peripheral = peripheral
        self.scanResponse = scanResponse
    }
    
    public var body: some View {
        StateView(
            peripheral: peripheral,
            scanResponse: scanResponse,
            manufacturerData: store[manufacturerData: peripheral],
            beacon: store[beacon: peripheral],
            key: accessoryID.flatMap { store.keys[$0] },
            characteristics: store.characteristics[peripheral] ?? [:]
        )
        .task { await reload() }
    }
}

internal extension NearbyAccessoryView {
    
    var accessoryID: UUID? {
        store[manufacturerData: peripheral]?.id ?? store[beacon: peripheral]?.uuid
    }
    
    func reload() async {
        do {
            try await store.central.connection(for: peripheral) { connection in
                // discover characteristics
                try await store.discoverCharacteristics(connection: connection)
                // read identifier
                let id = try await store.identifier(connection: connection)
                // read all non-list characteristics
                let keys = self.store.keys
                let key = keys[id]
                for (characteristic, cache) in (store.characteristics[peripheral] ?? [:]).sorted(by: { $0.key.id < $1.key.id }) {
                    // filter
                    let isEncrypted = cache.metadata.properties.contains(.encrypted)
                    let canRead = cache.metadata.properties.contains(.read) // must be readable
                        && !cache.metadata.properties.contains(.list) // will not read lists
                        && (!isEncrypted || key != nil) // must have key if encrypted
                    guard canRead else { continue }
                    let _ = try await store.read(
                        characteristic: characteristic,
                        connection: connection
                    )
                }
            }
        }
        catch {
            
        }
    }
}

internal extension NearbyAccessoryView {
    
    struct StateView: View {
        
        @EnvironmentObject
        var store: AccessoryManager
        
        let peripheral: AccessoryManager.Peripheral
        
        let scanResponse: AccessoryScanResponse
        
        let manufacturerData: AccessoryManufacturerData?
        
        let beacon: AccessoryBeacon?
        
        let key: Key?
        
        let characteristics: [AccessoryManager.Characteristic: CharacteristicCache]
        
        var body: some View {
            List {
                advertisementSection
                ForEach(services) { service in
                    Section(service.name) {
                        ForEach(service.characteristics) { characteristic in
                            AccessoryCharacteristicRow(
                                characteristic: characteristic.characteristic,
                                cache: characteristic.cache
                            )
                        }
                    }
                }
            }
            .navigationTitle(Text(verbatim: title))
        }
    }
}

internal extension NearbyAccessoryView.StateView {
    
    var title: String {
        scanResponse.name
    }
    
    var accessoryID: UUID? {
        manufacturerData?.id ?? beacon?.uuid
    }
    
    var advertisementSection: some View {
        Section("Advertisement") {
            if let accessoryType = manufacturerData?.accessoryType {
                SubtitleRow(
                    title: Text("Type"),
                    subtitle: Text(verbatim: accessoryType.description)
                )
            }
            SubtitleRow(
                title: Text("Service"),
                subtitle: Text(verbatim: "\(scanResponse.service)")
            )
            #if DEBUG
            SubtitleRow(
                title: Text("Peripheral"),
                subtitle: Text(verbatim: "\(peripheral.description)")
            )
            #endif
            if let id = accessoryID {
                SubtitleRow(
                    title: Text("Identifier"),
                    subtitle: Text(verbatim: id.description)
                )
            }
            if let isConfigured = manufacturerData?.isConfigured {
                SubtitleRow(
                    title: Text("Configured"),
                    subtitle: Text(verbatim: isConfigured.description)
                )
            }
        }
    }
    
    var services: [ServiceItem] {
        characteristicsByService.map { (service, characteristics) in
            ServiceItem(
                id: service,
                name: store.serviceTypes[service]?.description ?? service.description,
                characteristics: characteristics.sorted(by: { $0.cache.metadata.name < $1.cache.metadata.name })
            )
        }
        .sorted(by: { $0.name < $1.name })
        .sorted(by: { $0.id == BluetoothUUID(service: scanResponse.service) && $1.id != BluetoothUUID(service: scanResponse.service) })
        .sorted(by: { $0.id == BluetoothUUID(service: .information) && $1.id != BluetoothUUID(service: .information) })
    }
    
    var characteristicsByService: [BluetoothUUID: [CharacteristicItem]] {
        let blacklist: Set<BluetoothUUID> = [
            BluetoothUUID(characteristic: .authenticate),
            BluetoothUUID(characteristic: .cryptoHash)
        ]
        var characteristicsByService = [BluetoothUUID: [CharacteristicItem]]()
        for (characteristic, cache) in self.characteristics {
            guard blacklist.contains(characteristic.uuid) == false else {
                continue
            }
            let characteristicItem = CharacteristicItem(characteristic: characteristic, cache: cache)
            characteristicsByService[cache.service, default: []].append(characteristicItem)
        }
        return characteristicsByService
    }
}

internal extension NearbyAccessoryView.StateView {
    
    struct ServiceItem: Identifiable {
        
        let id: BluetoothUUID
        
        let name: String
        
        var characteristics: [CharacteristicItem]
    }
    
    struct CharacteristicItem: Identifiable {
        
        var id: BluetoothUUID {
            characteristic.uuid
        }
        
        let characteristic: AccessoryManager.Characteristic
        
        let cache: CharacteristicCache
    }
}