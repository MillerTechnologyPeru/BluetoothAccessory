//
//  NearbyDevicesView.swift
//  
//
//  Created by Alsey Coleman Miller on 3/25/23.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import DarwinGATT
import BluetoothAccessory
import SFSafeSymbols

public struct NearbyDevicesView: View {
    
    @EnvironmentObject
    var store: AccessoryManager
    
    @State
    private var scanTask: Task<Void, Never>?
    
    public init() { }
    
    public var body: some View {
        content
    }
}

extension NearbyDevicesView {
    
    struct NearbyAccessory: Equatable, Hashable, Identifiable {
        
        let peripheral: NativePeripheral
        
        var id: NativePeripheral.ID {
            return peripheral.id
        }
        
        let manufacturerData: AccessoryManufacturerData?
        
        let scanResponse: AccessoryScanResponse
        
        let beacon: AccessoryBeacon?
    }
    
    enum ScanState {
        case bluetoothUnavailable
        case scanning
        case stopScan
    }
    
    var items: [NearbyAccessory] {
        store.scanResponses
            .lazy
            .sorted(by: { $0.value.name < $1.value.name })
            .map {
                NearbyAccessory(
                    peripheral: $0.key,
                    manufacturerData: store[manufacturerData: $0.key],
                    scanResponse: $0.value,
                    beacon: store[beacon: $0.key]
                )
            }
    }
    
    var title: LocalizedStringKey {
        "Nearby"
    }
    
    var list: some View {
        List {
            ForEach(items) { (item) in
                NavigationLink(destination: {
                    NearbyAccessoryView(
                        peripheral: item.peripheral,
                        scanResponse: item.scanResponse
                    )
                }, label: {
                    ItemRow(item: item)
                })
            }
        }
    }
    
    var content: some View {
        list
        .navigationTitle(title)
        .toolbar {
            scanButton
        }
        .onAppear {
            scanTask?.cancel()
            scanTask = Task {
                // start scanning after delay
                try? await store.wait(for: .poweredOn)
                if store.isScanning == false {
                    toggleScan()
                }
            }
        }
        .onDisappear {
            scanTask?.cancel()
            scanTask = nil
            if store.isScanning {
                store.stopScanning()
            }
        }
    }
    
    var state: ScanState {
        if store.state != .poweredOn {
            return .bluetoothUnavailable
        } else if store.isScanning {
            return .scanning
        } else {
            return .stopScan
        }
    }
    
    var scanButton: some View {
        Button(action: {
            toggleScan()
        }, label: {
            switch state {
            case .bluetoothUnavailable:
                Image(systemSymbol: .exclamationmarkTriangleFill)
                    .symbolRenderingMode(.multicolor)
            case .scanning:
                Image(systemSymbol: .stopFill)
                    .symbolRenderingMode(.monochrome)
            case .stopScan:
                Image(systemSymbol: .arrowClockwise)
                    .symbolRenderingMode(.monochrome)
            }
        })
    }
    
    func toggleScan() {
        if store.isScanning {
            store.stopScanning()
        } else {
            self.scanTask?.cancel()
            self.scanTask = Task {
                guard await store.central.state == .poweredOn,
                      store.isScanning == false else {
                    return
                }
                do {
                    try await store.scan()
                }
                catch { store.log("⚠️ Unable to scan. \(error.localizedDescription)") }
            }
        }
    }
}

internal extension NearbyDevicesView {
    
    struct ItemRow: View {
        
        let item: NearbyDevicesView.NearbyAccessory
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(verbatim: item.scanResponse.name)
                    .font(.title3)
                if let id = item.manufacturerData?.id ?? item.beacon?.uuid {
                    Text(verbatim: id.description)
                }
                Text("Service: \("\(item.scanResponse.service)")")
                if let manufacturerData = item.manufacturerData {
                    Text("Type: \(manufacturerData.accessoryType.description)")
                    if manufacturerData.isConfigured == false {
                        Text("Ready for Setup")
                    }
                }
            }
        }
    }
}
