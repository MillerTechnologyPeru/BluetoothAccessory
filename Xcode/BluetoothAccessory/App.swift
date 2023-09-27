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
    
    static let accessoryManager = AccessoryManager(
        configuration: Self.configuration
    )
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    #elseif os(iOS) || os(tvOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    #endif
    
    @Environment(\.scenePhase)
    private var phase
    
    @StateObject
    var accessoryManager: AccessoryManager
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accessoryManager)
                .environment(\.managedObjectContext, accessoryManager.managedObjectContext)
        }
    }
    
    init() {
        let accessoryManager = Self.accessoryManager
        _accessoryManager = .init(wrappedValue: accessoryManager)
        // print version
        accessoryManager.log("Launching Bluetooth Accessory v\(Bundle.InfoPlist.shortVersion) (\(Bundle.InfoPlist.version))")
        Task {
            try? await Task.sleep(timeInterval: 0.2)
            await Self.didLaunch(accessoryManager)
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
            appGroup: "group.com.colemancda.BluetoothAccessory",
            keychain: (
                service: "com.colemancda.BluetoothAccessory",
                group: "4W79SG34MW.com.colemancda.BluetoothAccessory"
            ),
            cloud: "iCloud.com.colemancda.BluetoothAccessory"
        )
    }
}

private extension App {
    
    static func didLaunch(_ accessoryManager: AccessoryManager) async {
        // CloudKit discoverability
        do {
            guard try await accessoryManager.cloudContainer.accountStatus() == .available,
                  try await accessoryManager.cloudContainer.applicationPermissionStatus(for: .userDiscoverability) == .initialState
                else { return }
            let status = try await accessoryManager.cloudContainer.requestApplicationPermission(.userDiscoverability)
            accessoryManager.log("☁️ CloudKit permisions \(status == .granted ? "granted" : "not granted")")
        }
        catch { accessoryManager.log("⚠️ Could not request CloudKit permissions. \(error.localizedDescription)") }
    }
}

#if os(iOS) || os(tvOS)
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate { UIApplication.shared.delegate as! AppDelegate }
    
    let appLaunch = Date()
    
    private(set) var didBecomeActive: Bool = false
    
    var accessoryManager: AccessoryManager {
        BluetoothAccessoryApp.accessoryManager
    }
    
    // MARK: - UIApplicationDelegate
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
                
        #if DEBUG
        defer { accessoryManager.log("App finished launching in \(String(format: "%.3f", Date().timeIntervalSince(appLaunch)))s") }
        #endif
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        accessoryManager.log("Will resign active")
    }
}

#elseif os(macOS)
final class AppDelegate: NSResponder, NSApplicationDelegate {
    
    static var shared: AppDelegate { NSApplication.shared.delegate as! AppDelegate }
    
    var accessoryManager: AccessoryManager {
        BluetoothAccessoryApp.accessoryManager
    }
    
    // MARK: - NSApplicationDelegate
        
    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return false
    }
}
#endif
