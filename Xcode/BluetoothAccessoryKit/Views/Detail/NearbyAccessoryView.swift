//
//  NearbyAccessoryView.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import SwiftUI
import CoreData
import Bluetooth
import GATT
import DarwinGATT
import BluetoothAccessory
import SFSafeSymbols

public struct NearbyAccessoryView: View {
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @Environment(\.managedObjectContext)
    private var managedObjectContext
    
    let peripheral: AccessoryManager.Peripheral
    
    let scanResponse: AccessoryScanResponse
    
    @State
    private var cachedID: UUID?
    
    @State
    private var error: String?
    
    @State
    private var isReloading = false
    
    @State
    private var canShowActivityIndicator = true
    
    @State
    private var characteristics: [CharacteristicCache] = []
    
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
            key: cachedID.flatMap { store[cache: $0]?.key },
            characteristics: characteristics,
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
        store[manufacturerData: peripheral]?.id ?? store[beacon: peripheral]?.accessory
    }
    
    var isConnected: Bool {
        store.peripherals[peripheral] ?? false
    }
    
    var leftBarButtonItem: some View {
        if isReloading, canShowActivityIndicator {
            #if os(iOS) || os(visionOS)
            return AnyView(
                ProgressView()
                    .progressViewStyle(.circular)
            )
            #elseif os(macOS)
            return AnyView(EmptyView())
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
            #elseif os(iOS) || os(visionOS)
            return AnyView(EmptyView()) // only pull to refresh supported
            #endif
        }
    }
    
    var blacklist: Set<BluetoothUUID> {
        // hide authentication characteristics
        var blacklist: Set<CharacteristicType> = [
            .authenticate,
            .cryptoHash,
            .isConfigured,
            .metadata,
            .createKey,
            .removeKey
        ]
        
        // hide setup if configured
        let isConfigured = characteristics.first(where: { $0.service == BluetoothUUID(service: .authentication) && $0.metadata.type == BluetoothUUID(characteristic: .isConfigured) })?.value == true
        #if os(iOS)
        if isConfigured {
            blacklist.insert(.setup) // hide setup
        }
        #else
        blacklist.insert(.setup) // can only setup on iOS
        #endif
        
        // hide admin key characteristics if not admin
        if let id = self.cachedID, let key = store[cache: id]?.key, key.permission.isAdministrator {
            //
        } else {
            blacklist.insert(.keys)
        }
        
        // hide confirm key if already have key or not setup
        if isConfigured == false {
            blacklist.insert(.confirmKey)
        } else if let id = self.cachedID, let _ = store[cache: id] {
            blacklist.insert(.confirmKey)
        }
        
        return Set(blacklist.lazy.map { BluetoothUUID(characteristic: $0) })
    }
    
    func reload() async {
        self.error = nil
        self.isReloading = true
        defer { isReloading = false }
        do {
            // load cache
            Task {
                if let id = self.cachedID {
                    self.characteristics = try await store.characteristics(for: id)
                }
            }
            // connect
            try await store.connection(for: peripheral) { connection in
                // discover characteristics
                let characteristics = try await store.discoverCharacteristics(connection: connection)
                // read identifier
                let id = try await store.identifier(connection: connection)
                self.cachedID = id
                self.characteristics = try await store.characteristics(for: id)
                // read all non-list characteristics
                let key = self.store[cache: id]?.key
                assert(characteristics.isEmpty == false)
                for (service, metadata) in characteristics {
                    // filter
                    let isEncrypted = metadata.properties.contains(.encrypted)
                    let canRead = metadata.properties.contains(.read) // must be readable
                        && !metadata.properties.contains(.list) // will not read lists
                        && (!isEncrypted || key != nil) // must have key if encrypted
                    guard canRead else { continue }
                    let _ = try await store.read(
                        characteristic: metadata.type,
                        service: service,
                        connection: connection
                    )
                    self.characteristics = try await store.characteristics(for: id)
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
        
        let peripheral: AccessoryManager.Peripheral
        
        let scanResponse: AccessoryScanResponse
        
        let manufacturerData: AccessoryManufacturerData?
        
        let beacon: AccessoryBeacon?
        
        let key: Key?
        
        let characteristics: [CharacteristicCache]
        
        let blacklist: Set<BluetoothUUID>
        
        let error: String?
        
        var body: some View {
            List {
                advertisementSection
                ForEach(services) { service in
                    Section(service.name) {
                        ForEach(service.characteristics) { characteristic in
                            AccessoryCharacteristicRow(
                                characteristic: characteristic
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
    
    var advertisedID: UUID? {
        manufacturerData?.id ?? beacon?.accessory
    }
    
    var advertisementSection: some View {
        Section(content: {
            if let accessoryType = manufacturerData?.type {
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
            if let id = advertisedID {
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
        }, header: { Text("Advertisement") }, footer: { error.flatMap { Text(verbatim: $0) } })
    }
    
    var services: [ServiceItem] {
        characteristicsByService.map { (service, characteristics) in
            ServiceItem(
                id: service,
                name: BluetoothUUID.accessoryServiceTypes[service]?.description ?? service.description,
                characteristics: characteristics.sorted(by: { $0.metadata.name < $1.metadata.name })
            )
        }
        .filter { $0.characteristics.isEmpty == false }
        .sorted(by: { $0.name < $1.name })
        .sorted(by: { $0.id == BluetoothUUID(service: scanResponse.service) && $1.id != BluetoothUUID(service: scanResponse.service) })
        .sorted(by: { $0.id != BluetoothUUID(service: .information) && $1.id == BluetoothUUID(service: .information) })
    }
    
    var characteristicsByService: [BluetoothUUID: [CharacteristicCache]] {
        var characteristicsByService = [BluetoothUUID: [CharacteristicCache]]()
        for cache in self.characteristics {
            guard blacklist.contains(cache.metadata.type) == false else {
                continue
            }
            characteristicsByService[cache.service, default: []].append(cache)
        }
        return characteristicsByService
    }
}

internal extension NearbyAccessoryView.StateView {
    
    struct ServiceItem: Identifiable {
        
        let id: BluetoothUUID
        
        let name: String
        
        var characteristics: [CharacteristicCache]
    }
}
