//
//  AccessoryManagerPreferences.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/3/24.
//

import Foundation

public extension AccessoryManager {
    
    /// User UUID.
    var user: UUID {
        get {
            if let user = preferences.user {
                return user
            } else {
                // create new UUID
                let user = UUID()
                preferences.user = user
                return user
            }
        }
        set {
            preferences.user = newValue
        }
    }
}
