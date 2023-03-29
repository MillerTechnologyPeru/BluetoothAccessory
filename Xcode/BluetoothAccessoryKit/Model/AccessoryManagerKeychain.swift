//
//  KeychainStore.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import KeychainAccess
import BluetoothAccessory

public extension AccessoryManager {
    
    func secret(for key: UUID) throws -> KeyData {
        // TODO
        fatalError()
    }
}

internal extension AccessoryManager {
    
    func loadKeychain() -> Keychain {
        return Keychain(
            service: configuration.keychain.service,
            accessGroup: configuration.keychain.group
        )
    }
}

public extension AccessoryManager.Configuration {
    
    struct Keychain: Equatable, Hashable {
        
        public var group: String
        
        public var service: String
        
        public init(group: String, service: String) {
            self.group = group
            self.service = service
        }
    }
}
