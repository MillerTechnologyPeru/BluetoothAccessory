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
    
    @Binding
    var selection: UUID?
    
    public init(selection: Binding<UUID?>) {
        _selection = selection
    }
    
    public init(url: Binding<AccessoryURL?>) {
        _selection = Binding(get: {
            return url.wrappedValue?.accessory
        }, set: { newValue in
            url.wrappedValue = newValue.flatMap { .accessory($0) }
        })
    }
    
    public var body: some View {
        VStack {
            if accessories.isEmpty {
                VStack {
                    Text("No paired accessories")
                }
            } else {
                List {
                    ForEach(accessories) { accessory in
                        NavigationLink(
                            isActive: isActiveBinding(for: accessory.id),
                            destination: {
                                AccessoryDetailView(accessory: accessory.id)
                            }, label: {
                                AccessoryRow(accessory: accessory)
                            }
                        )
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
    
    func isActiveBinding(for destination: UUID) -> Binding<Bool> {
        Binding(get: {
                guard let selection = self.selection else { return false }
                return destination == selection
        }, set: { isActive in
            if isActive {
                self.selection = destination
            }
        })
    }
}
