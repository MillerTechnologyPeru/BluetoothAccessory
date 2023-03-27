//
//  BluetoothAccessoryApp.swift
//  BluetoothAccessory
//
//  Created by Alsey Coleman Miller on 3/25/23.
//

import SwiftUI
import BluetoothAccessoryKit

@main
struct BluetoothAccessoryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AccessoryManager.shared)
        }
    }
}
