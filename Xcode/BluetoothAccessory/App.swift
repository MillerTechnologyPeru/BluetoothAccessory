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
    
    @StateObject
    var accessoryManager = AccessoryManager(
        configuration: Self.configuration
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accessoryManager)
        }
    }
}

extension BluetoothAccessoryApp {
    
    static var configuration: AccessoryManager.Configuration {
        AccessoryManager.Configuration(
            central: NativeCentral.Options(
                showPowerAlert: true,
                restoreIdentifier: "com.colemancda.BluetoothAccessory.CBCentralManager"
            ),
            keychain: "com.colemancda.BluetoothAccessory",
            appGroup: "4W79SG34MW.com.colemancda.BluetoothAccessory",
            cloud: "iCloud.com.colemancda.BluetoothAccessory"
        )
    }
}
