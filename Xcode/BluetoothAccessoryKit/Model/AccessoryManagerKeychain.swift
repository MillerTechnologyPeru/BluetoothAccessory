//
//  KeychainStore.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Dispatch
import KeychainAccess
import BluetoothAccessory

// MARK: - Subscript

public extension AccessoryManager {
    
    /// Private Key for the specified accessory.
    internal(set) subscript (key id: UUID) -> KeyData? {
        
        get {
            
            do {
                guard let data = try keychain.getData(id.uuidString)
                    else { return nil }
                guard let key = KeyData(data: data)
                    else { assertionFailure("Invalid key data"); return nil }
                return key
            } catch {
                #if DEBUG
                print(error)
                #endif
                assertionFailure("Unable retrieve value from keychain: \(error)")
                return nil
            }
        }
        
        set {
            let key = id.uuidString
            do {
                guard let data = newValue?.data else {
                    try keychain.remove(key)
                    return
                }
                if try keychain.contains(key) {
                    try keychain.remove(key)
                }
                try keychain.set(data, key: key)
            }
            catch {
                #if DEBUG
                print(error)
                #endif
                assertionFailure("Unable store value in keychain: \(error)")
            }
        }
    }
}

// MARK: - Methods

public extension AccessoryManager {
    
    /// Remove the specified accessory from the cache and keychain.
    @discardableResult
    func remove(_ accessory: UUID) -> Bool {
        
        guard let accessoryCache = self[cache: accessory]
            else { return false }
        
        self[cache: accessory] = nil
        self[key: accessoryCache.key.id] = nil
        
        return true
    }
    
    /// Get credentials from Keychain to authorize requests.
    func key(for accessory: UUID) -> Credential? {
        guard let cache = self[cache: accessory],
            let keyData = self[key: cache.key.id]
            else { return nil }
        return .init(id: cache.key.id, secret: keyData)
    }
}

// MARK: - Internal Methods

internal extension AccessoryManager {
    
    func loadKeychain() -> Keychain {
        let keychain = Keychain(
            service: configuration.keychain,
            accessGroup: configuration.appGroup
        )
        // reset if new installation
        clearKeychainNewInstall()
        return keychain
    }
}

private extension AccessoryManager {
    
    /// Clear keychain on newly installed app.
    private func clearKeychainNewInstall() {
        
        if preferences.isAppInstalled == false {
            preferences.isAppInstalled = true
            do { try keychain.removeAll() }
            catch {
                log("⚠️ Unable to clear keychain: \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    #if DEBUG
                    print(error)
                    #endif
                    assertionFailure("Unable to clear keychain")
                }
            }
        }
    }
}
