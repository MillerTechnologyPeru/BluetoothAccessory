//
//  AppClip.swift
//  Clip
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import SwiftUI
import BluetoothAccessory

@main
struct AccessoryAppClip: App {
    
    @MainActor
    static let accessoryManager = AccessoryManager(
        configuration: .default
    )
    
    @StateObject
    var accessoryManager: AccessoryManager
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Self.accessoryManager)
                .environment(\.managedObjectContext, accessoryManager.managedObjectContext)
        }
    }
    
    init() {
        let accessoryManager = Self.accessoryManager
        _accessoryManager = .init(wrappedValue: accessoryManager)
        // print version
        accessoryManager.log("Launching Bluetooth Accessory App Clip v\(Bundle.InfoPlist.shortVersion) (\(Bundle.InfoPlist.version))")
        Task {
            try? await Task.sleep(timeInterval: 0.2)
            await Self.didLaunch(accessoryManager)
        }
    }
}

private extension App {
    
    static func didLaunch(_ accessoryManager: AccessoryManager) async {
        Task {
            try? await accessoryManager.wait(for: .poweredOn)
            try? await accessoryManager.scan(duration: 2.0)
        }
    }
}
