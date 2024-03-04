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
    
    @State
    var showSetup = false
    
    /*
    @Binding
    var showSetup: Bool
    
    public init(showSetup: Binding<Bool>) {
        _showSetup = showSetup
    }
    */
    
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
                        AccessoryRow(accessory: accessory)
                    }
                }
            }
        }
        .navigationTitle("Devices")
#if !APPCLIP
        .toolbar {
            
            Button(action: {
                add()
            }, label: {
                Image(systemSymbol: .plus)
            })
        }
        .sheet(isPresented: $showSetup) {
            NavigationView {
                SetupAccessoryView()
            }
        }
#endif
    }
}

private extension AccessoriesView {
    
    var accessories: [PairedAccessory] {
        store.cache.values
            .sorted(by: { $0.information.type.rawValue < $1.information.type.rawValue })
            .sorted(by: { $0.name < $1.name })
    }
    
    func add() {
        showSetup = true
    }
}

#Preview {
    AccessoriesView()
}
