//
//  AuthenticationManager.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

import Foundation
import Bluetooth
import BluetoothAccessory

public actor AuthenticationManager {
    
    public let configurationURL: URL
    
    public let authenticationURL: URL
    
    private let fileManager = FileManager()
    
    public init(configurationURL: URL, authenticationURL: URL) {
        self.configurationURL = configurationURL
        self.authenticationURL = authenticationURL
    }
}

// MARK: - Methods

private extension AuthenticationManager {
    
    var configuration: AccessoryConfiguration {
        get throws {
            return try AccessoryConfiguration(url: configurationURL)
        }
    }
    
    func authenticationFile<T>(_ block: (inout AuthenticationFile) -> T) throws -> T {
        let url = authenticationURL
        var file: AuthenticationFile
        // create or read file
        if fileManager.fileExists(atPath: url.path) {
            file = try AuthenticationFile(url: url)
        } else {
            file = AuthenticationFile()
            try fileManager.createFile(atPath: url.path, contents: file.encode())
        }
        let oldHash = file.hashValue
        let result = block(&file)
        // save file if changed
        if oldHash != file.hashValue {
            try file.encode().write(to: url, options: [.atomic])
        }
        return result
    }
}

// MARK: - AuthenticationDelegate

extension AuthenticationManager: AuthenticationDelegate {
    
    public var isConfigured: Bool {
        do {
            return try authenticationFile { $0.isConfigured }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return false
        }
    }
    
    public var allKeys: [BluetoothAccessory.KeysCharacteristic.Item] {
        get {
            do {
                var list = [BluetoothAccessory.KeysCharacteristic.Item]()
                try authenticationFile {
                    $0.keys.forEach {
                        list.append(.key($0.value))
                    }
                    $0.newKeys.forEach {
                        list.append(.newKey($0.value))
                    }
                }
                return list
            }
            catch {
                assertionFailure("\(#function) \(error)")
                return []
            }
        }
    }
    
    public func key(for id: UUID) -> BluetoothAccessory.Key? {
        do {
            return try authenticationFile {
                $0.keys[id]
            }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return nil
        }
    }
    
    public func newKey(for id: UUID) -> BluetoothAccessory.NewKey? {
        do {
            return try authenticationFile {
                $0.newKeys[id]
            }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return nil
        }
    }
    
    public func secret(for id: UUID) -> BluetoothAccessory.KeyData? {
        do {
            guard id != Key.setup else {
                // return setup shared secret
                return try configuration.setupSecret
            }
            return try authenticationFile {
                $0.secretData[id]
            }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return nil
        }
    }
    
    public func setup(_ request: BluetoothAccessory.SetupRequest, authenticationMessage: BluetoothAccessory.AuthenticationMessage) async -> Bool {
        do {
            return try authenticationFile {
                // can only be setup once
                guard $0.isConfigured == false else {
                    return false
                }
                let ownerKey = Key(setup: request)
                $0 = .init(owner: ownerKey, secret: request.secret)
                return true
            }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return false
        }
    }
    
    public func create(_ request: BluetoothAccessory.CreateNewKeyRequest, authenticationMessage: BluetoothAccessory.AuthenticationMessage) async -> Bool {
        do {
            return try authenticationFile {
                // must be setup first
                guard $0.isConfigured else {
                    return false
                }
                let newKey = NewKey(request: request)
                $0.newKeys[newKey.id] = newKey
                $0.secretData[newKey.id] = request.secret
                return true
            }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return false
        }
    }
    
    public func confirm(_ request: BluetoothAccessory.ConfirmNewKeyRequest, authenticationMessage: BluetoothAccessory.AuthenticationMessage) async -> Bool {
        do {
            return try authenticationFile {
                // must be setup first
                guard $0.isConfigured else {
                    return false
                }
                guard let invitation = $0.newKeys[authenticationMessage.id] else {
                    return false
                }
                let key = invitation.confirm()
                $0.newKeys[key.id] = nil
                $0.keys[key.id] = key
                $0.secretData[key.id] = request.secret
                return true
            }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return false
        }
    }
    
    public func remove(_ request: BluetoothAccessory.RemoveKeyRequest, authenticationMessage: BluetoothAccessory.AuthenticationMessage) async -> Bool {
        do {
            return try authenticationFile {
                // must be setup first
                guard $0.isConfigured else {
                    return false
                }
                // verify requestee is admin
                
                // verify key exists
                guard $0.keys.keys.contains(request.id) && $0.newKeys.keys.contains(request.id) else {
                    return false
                }
                if $0.keys.keys.contains(request.id) {
                    $0.keys.removeValue(forKey: request.id)
                    return true
                } else if $0.newKeys.keys.contains(request.id) {
                    $0.newKeys.removeValue(forKey: request.id)
                    return true
                } else {
                    return false
                }
            }
        }
        catch {
            assertionFailure("\(#function) \(error)")
            return false
        }
    }
}
