//
//  AccessoryDetailView.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import SwiftUI
import Bluetooth
import BluetoothAccessory

public struct AccessoryDetailView: View {
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @Environment(\.managedObjectContext)
    private var managedObjectContext
    
    let accessory: UUID
    
    @State
    private var isReloading = false
    
    @State
    private var characteristics: [CharacteristicCache] = []
    
    public init(accessory: UUID) {
        self.accessory = accessory
    }
    
    public var body: some View {
        VStack {
            if let cache = store[cache: accessory] {
                PairedAccessoryView(accessory: cache)
                    .task { await reload() }
            } else {
                Text("Accessory \(accessory) not paired.")
                    .navigationTitle("Accessory")
            }
        }
    }
}

private extension AccessoryDetailView {
    
    var accessoryBinding: Binding<PairedAccessory?> {
        Binding(get: {
            store[cache: accessory]
        }, set: { newValue in
            if let newValue {
                store[cache: accessory] = newValue
            } else {
                store.remove(accessory)
            }
        })
    }
    
    func reload() async {/*
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
        */
    }
}

internal extension AccessoryDetailView {
    
    struct ServiceItem: Identifiable {
        
        let id: BluetoothUUID
        
        let name: String
        
        var characteristics: [CharacteristicCache]
    }
}

internal extension AccessoryDetailView {
    
    struct PairedAccessoryView: View {
        
        let accessory: PairedAccessory
        
        //let services: [ServiceItem]
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    if #available(iOS 16, macOS 13, *) {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemSymbol: accessory.information.type.symbol)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(maxHeight: 150)
                    }
                    /*
                    ForEach(services) { service in
                        Section(service.name) {
                            ForEach(service.characteristics) { characteristic in
                                AccessoryCharacteristicRow(
                                    characteristic: characteristic
                                )
                            }
                        }
                    }*/
                }
                .padding()
            }
            .navigationTitle("\(accessory.name)")
        }
    }
}
/*
private extension AccessoryDetailView.PairedAccessoryView {
    
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
}
*/
// MARK: - Preview

#Preview {
    NavigationStack {
        AccessoryDetailView.PairedAccessoryView(
            accessory: PairedAccessory(
                information: AccessoryInformation(
                    id: UUID(),
                    name: "Smart Bulb",
                    type: .lightbulb,
                    service: .lightbulb,
                    manufacturer: "Smart Home Inc.",
                    serialNumber: UUID().uuidString,
                    model: "Bulb101",
                    softwareVersion: "1.0.5"
                ),
                key: Key(
                    user: UUID(),
                    permission: .owner
                ),
                name: "Living Room Lamp"
            )/*
            characteristics: [
                CharacteristicCache(
                    accessory: accessory.id,
                    service: BluetoothUUID(service: .information),
                    metadata: CharacteristicMetadata(type: .identifier),
                    value: .single(.uuid(accessory.id)),
                    updated: Date()
                ),
                CharacteristicCache(
                    accessory: accessory.id,
                    service: BluetoothUUID(service: .information),
                    metadata: CharacteristicMetadata(type: .firmwareVersion),
                    value: .single(.string("1.0.5")),
                    updated: Date()
                )
                
            ]*/
        )
    }
}
