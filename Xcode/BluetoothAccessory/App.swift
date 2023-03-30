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
    var accessoryManager: AccessoryManager
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accessoryManager)
        }
    }
    
    init() {
        let accessoryManager = AccessoryManager(
            configuration: Self.configuration
        )
        _accessoryManager = .init(wrappedValue: accessoryManager)
        // print version
        accessoryManager.log("Launching Bluetooth Accessory v\(Bundle.InfoPlist.shortVersion) (\(Bundle.InfoPlist.version))")
    }
}

extension BluetoothAccessoryApp {
    
    static var configuration: AccessoryManager.Configuration {
        AccessoryManager.Configuration(
            central: NativeCentral.Options(
                showPowerAlert: true,
                restoreIdentifier: "com.colemancda.BluetoothAccessory.CBCentralManager"
            ),
            appGroup: "group.com.colemancda.BluetoothAccessory",
            keychain: (
                service: "com.colemancda.BluetoothAccessory",
                group: "4W79SG34MW.com.colemancda.BluetoothAccessory"
            ),
            cloud: "iCloud.com.colemancda.BluetoothAccessory"
        )
    }
}
