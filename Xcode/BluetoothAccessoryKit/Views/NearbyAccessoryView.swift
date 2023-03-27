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
            key: accessoryID.flatMap { store.keys[$0] }
        )
    }
}

internal extension NearbyAccessoryView {
    
    var accessoryID: UUID? {
        store[manufacturerData: peripheral]?.id ?? store[beacon: peripheral]?.uuid
    }
}

internal extension NearbyAccessoryView {
    
    struct StateView: View {
        
        let peripheral: AccessoryManager.Peripheral
        
        let scanResponse: AccessoryScanResponse
        
        let manufacturerData: AccessoryManufacturerData?
        
        let beacon: AccessoryBeacon?
        
        let key: Key?
        
        var body: some View {
            List {
                advertisementSection
            }
            .padding(20)
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
}
