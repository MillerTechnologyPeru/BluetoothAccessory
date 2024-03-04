//
//  AccessoryRow.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import SwiftUI
import BluetoothAccessory

struct AccessoryRow: View {
    
    let accessory: PairedAccessory
    
    var body: some View {
        VStack(alignment: .leading) {
            if #available(iOS 16.0, *) {
                Label("\(accessory.name)", systemSymbol: accessory.information.type.symbol)
            } else {
                Text("\(accessory.name)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        AccessoryRow(accessory: PairedAccessory(
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
        ))
        AccessoryRow(accessory: PairedAccessory(
            information: AccessoryInformation(
                id: UUID(),
                name: "Smart Lock",
                type: .doorLock,
                service: .lock,
                manufacturer: "Smart Home Inc.",
                serialNumber: UUID().uuidString,
                model: "Lock201",
                softwareVersion: "1.0.2"
            ),
            key: Key(
                user: UUID(),
                permission: .owner
            ),
            name: "Front Door"
        ))
    }
}
