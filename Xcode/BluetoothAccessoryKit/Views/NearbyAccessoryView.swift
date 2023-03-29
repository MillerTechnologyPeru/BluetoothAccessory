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
import SFSafeSymbols

public struct NearbyAccessoryView: View {
    
    @EnvironmentObject
    var store: AccessoryManager
    
    let peripheral: AccessoryManager.Peripheral
    
    let scanResponse: AccessoryScanResponse
    
    @State
    var cachedID: UUID?
    
    @State
    var error: String?
    
    @State
    var isReloading = false
    
    @State
    var canShowActivityIndicator = true
    
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
            key: cachedID.flatMap { store.keys[$0] },
            characteristics: store.characteristics[peripheral] ?? [:],
            blacklist: blacklist,
            error: error
        )
        .task {
            canShowActivityIndicator = true
            await reload()
        }
        .refreshable {
            canShowActivityIndicator = false
            await reload()
        }
        .toolbar { leftBarButtonItem }
    }
}

internal extension NearbyAccessoryView {
    
    var advertisementID: UUID? {
        store[manufacturerData: peripheral]?.id ?? store[beacon: peripheral]?.uuid
    }
    
    var isConnected: Bool {
        store.peripherals[peripheral] ?? false
    }
    
    var leftBarButtonItem: some View {
        if isReloading, canShowActivityIndicator {
            #if os(iOS)
            return AnyView(
                ProgressView()
                    .progressViewStyle(.circular)
            )
            #elseif os(macOS)
            return EmptyView()
            #endif
        } else if error != nil {
            return AnyView(
                Image(systemSymbol: .exclamationmarkTriangleFill)
                    .symbolRenderingMode(.multicolor)
            )
        } else {
            #if os(macOS)
            return AnyView(Button(action: {
                Task {
                    await reload()
                }
            }) {
                Image(systemSymbol: .arrowClockwise)
            })
            #elseif os(iOS)
            return AnyView(EmptyView()) // only pull to refresh supported
            #endif
        }
    }
    
    var blacklist: Set<BluetoothUUID> {
        // hide authentication characteristics
        var blacklist: Set<BluetoothUUID> = [
            BluetoothUUID(characteristic: .authenticate),
            BluetoothUUID(characteristic: .cryptoHash),
            BluetoothUUID(characteristic: .isConfigured),
            BluetoothUUID(characteristic: .metadata),
        ]
        let characteristics = store.characteristics[peripheral] ?? [:]
        
        // hide setup if configured
        let isConfigured = characteristics.values.first(where: { $0.service == BluetoothUUID(service: .authentication) && $0.metadata.type == BluetoothUUID(characteristic: .isConfigured) })?.value == true
        if isConfigured {
            blacklist.insert(BluetoothUUID(characteristic: .setup)) // hide setup
        }
        
        // hide admin key characteristics if not admin
        if let id = self.cachedID, let key = store.keys[id], key.permission.isAdministrator {
            // 
        } else {
            blacklist.insert(BluetoothUUID(characteristic: .createKey))
            blacklist.insert(BluetoothUUID(characteristic: .removeKey))
            blacklist.insert(BluetoothUUID(characteristic: .keys))
        }
        
        // hide confirm key if already have key or not setup
        if isConfigured == false {
            blacklist.insert(BluetoothUUID(characteristic: .confirmKey))
        } else if let id = self.cachedID, let _ = store.keys[id] {
            blacklist.insert(BluetoothUUID(characteristic: .confirmKey))
        }
        
        return blacklist
    }
    
    func reload() async {
        self.error = nil
        self.isReloading = true
        defer { isReloading = false }
        do {
            try await store.connection(for: peripheral) { connection in
                // discover characteristics
                try await store.discoverCharacteristics(connection: connection)
                // read identifier
                let id = try await store.identifier(connection: connection)
                self.cachedID = cachedID
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
            self.error = error.localizedDescription
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
        
        let blacklist: Set<BluetoothUUID>
        
        let error: String?
        
        var body: some View {
            List {
                advertisementSection
                ForEach(services) { service in
                    Section(service.name) {
                        ForEach(service.characteristics) { characteristic in
                            AccessoryCharacteristicRow(
                                characteristic: characteristic.cache
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
                name: BluetoothUUID.accessoryServiceTypes[service]?.description ?? service.description,
                characteristics: characteristics.sorted(by: { $0.cache.metadata.name < $1.cache.metadata.name })
            )
        }
        .sorted(by: { $0.name < $1.name })
        .sorted(by: { $0.id == BluetoothUUID(service: scanResponse.service) && $1.id != BluetoothUUID(service: scanResponse.service) })
        .sorted(by: { $0.id == BluetoothUUID(service: .information) && $1.id != BluetoothUUID(service: .information) })
    }
    
    var characteristicsByService: [BluetoothUUID: [CharacteristicItem]] {
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
