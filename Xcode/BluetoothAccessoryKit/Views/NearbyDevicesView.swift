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
import BluetoothAccessory

public struct NearbyDevicesView: View {
    
    @EnvironmentObject
    var store: AccessoryStore
    
    @State
    private var scanTask: Task<Void, Never>?
    
    public init() { }
    
    public var body: some View {
        content
    }
}

extension NearbyDevicesView {
    
    enum ScanState {
        case bluetoothUnavailable
        case scanning
        case stopScan
    }
    
    typealias Item = AccessoryPeripheral<NativePeripheral>
    
    var items: [Item] {
        store.peripherals
            .lazy
            .sorted(by: { $0.value.name < $1.value.name })
            .map { $0.value }
    }
    
    var title: LocalizedStringKey {
        "Nearby"
    }
    
    var list: some View {
        List {
            ForEach(items) {
                ItemRow(item: $0, manufacturerData: store.manufacturerData[$0.peripheral])
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
                try? await store.central.wait(for: .poweredOn)
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
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
            case .scanning:
                Image(systemName: "stop.fill")
                    .symbolRenderingMode(.monochrome)
            case .stopScan:
                Image(systemName: "arrow.clockwise")
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
        
        let item: NearbyDevicesView.Item
        
        let manufacturerData: AccessoryManufacturerData?
        
        var body: some View {
            VStack {
                Text(verbatim: item.name)
                    .font(.title3)
                Text(verbatim: item.id.description)
                Text("Service \("\(item.service)")")
                if let manufacturerData = manufacturerData {
                    Text("Type \(manufacturerData.accessoryType.description)")
                    if manufacturerData.isConfigured {
                        Text("Configured")
                    } else {
                        Text("Ready for Setup")
                    }
                }
            }
        }
    }
}
