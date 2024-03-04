//
//  AccessoriesView.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import DarwinGATT
import BluetoothAccessory
import SFSafeSymbols

/// List of Paired Accessories
public struct AccessoriesView: View {
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    public init() { }
    
    public var body: some View {
        VStack {
            if accessories.isEmpty {
                VStack {
                    Text("No paired accessories")
                }
            } else {
                List {
                    ForEach(accessories) { accessory in
                        Link(destination: URL(AccessoryURL.accessory(accessory.id)), label: {
                            AccessoryRow(accessory: accessory)
                        })
                    }
                }
            }
        }
        .navigationTitle("Devices")
    }
}

private extension AccessoriesView {
    
    var accessories: [PairedAccessory] {
        store.cache.values
            .sorted(by: { $0.information.type.rawValue < $1.information.type.rawValue })
            .sorted(by: { $0.name < $1.name })
    }
}

#Preview {
    AccessoriesView()
}
