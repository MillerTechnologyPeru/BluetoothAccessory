//
//  Preferences.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Combine

/// Preferences
public final class Preferences: ObservableObject {
    
    // MARK: - Preferences
    
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Methods
    
    internal subscript <T> (key: Key) -> T? {
        get { userDefaults.object(forKey: key.rawValue) as? T }
        set {
            objectWillChange.send()
            userDefaults.set(newValue, forKey: key.rawValue)
        }
    }
}

// MARK: - App Group

public extension Preferences {
    
    static let standard = Preferences(userDefaults: .standard)
}

public extension Preferences {
    
    convenience init?(suiteName: String) {
        guard let userDefaults = UserDefaults(suiteName: suiteName)
            else { return nil }
        self.init(userDefaults: userDefaults)
    }
}

// MARK: - Accessors

public extension Preferences {
    
    var user: UUID? {
        get { return (self[.user] as String?).flatMap { UUID(uuidString: $0) } }
        set { self[.user] = newValue?.uuidString }
    }
    
    var isAppInstalled: Bool {
        get { return self[.isAppInstalled] ?? false }
        set { self[.isAppInstalled] = newValue }
    }
    
    var appVersion: String? {
        get { return self[.appVersion] }
        set { self[.appVersion] = newValue }
    }
    
    var isCloudBackupEnabled: Bool {
        get {
            let defaultValue = true
            return self[.isCloudBackupEnabled] ?? defaultValue
        }
        set { self[.isCloudBackupEnabled] = newValue }
    }
    
    var lastCloudUpdate: Date? {
        get { return self[.lastCloudUpdate] }
        set { self[.lastCloudUpdate] = newValue }
    }
    
    var lastWatchUpdate: Date? {
        get { return self[.lastWatchUpdate] }
        set { self[.lastWatchUpdate] = newValue }
    }
    
    var bluetoothTimeout: TimeInterval {
        get { return self[.bluetoothTimeout] ?? 15.0 }
        set { self[.bluetoothTimeout] = newValue }
    }
    
    var scanDuration: TimeInterval {
        get { return self[.scanDuration] ?? 3.0 }
        set { self[.scanDuration] = newValue }
    }
    
    var filterDuplicates: Bool {
        get { return self[.filterDuplicates] ?? true }
        set { self[.filterDuplicates] = newValue }
    }
    
    var writeWithoutResponseTimeout: TimeInterval {
        get { return self[.writeWithoutResponseTimeout] ?? 3.0 }
        set { self[.writeWithoutResponseTimeout] = newValue }
    }
    
    var showPowerAlert: Bool {
        get { return self[.showPowerAlert] ?? false }
        set { self[.showPowerAlert] = newValue }
    }
    
    var monitorBluetoothNotifications: Bool {
        get { return self[.monitorBluetoothNotifications] ?? true }
        set { self[.monitorBluetoothNotifications] = newValue }
    }
}

// MARK: - Supporting Types

public extension Preferences {
    
    enum Key: String, CaseIterable {
        
        case user                               = "com.colemancda.BluetoothAccessory.UserDefaults.User"
        case isAppInstalled                     = "com.colemancda.BluetoothAccessory.UserDefaults.AppInstalled"
        case appVersion                         = "com.colemancda.BluetoothAccessory.UserDefaults.AppVersion"
        case isCloudBackupEnabled               = "com.colemancda.BluetoothAccessory.UserDefaults.CloudBackupEnabled"
        case lastCloudUpdate                    = "com.colemancda.BluetoothAccessory.UserDefaults.CloudUpdate"
        case lastWatchUpdate                    = "com.colemancda.BluetoothAccessory.UserDefaults.WatchUpdate"
        case bluetoothTimeout                   = "com.colemancda.BluetoothAccessory.UserDefaults.BluetoothTimeout"
        case filterDuplicates                   = "com.colemancda.BluetoothAccessory.UserDefaults.FilterDuplicates"
        case showPowerAlert                     = "com.colemancda.BluetoothAccessory.UserDefaults.ShowPowerAlert"
        case writeWithoutResponseTimeout        = "com.colemancda.BluetoothAccessory.UserDefaults.WriteWithoutResponseTimeout"
        case scanDuration                       = "com.colemancda.BluetoothAccessory.UserDefaults.ScanDuration"
        case monitorBluetoothNotifications      = "com.colemancda.BluetoothAccessory.UserDefaults.MonitorBluetoothNotifications"
    }
}
