//
//  AuthenticationFile.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

import Foundation
import Bluetooth
import BluetoothAccessory

/// Bluetooth Accessory Authentication File.
public struct AuthenticationFile: Equatable, Hashable, Codable, JSONFile {
    
    public var keys: [UUID: Key]
    
    public var newKeys: [UUID: NewKey]
    
    public var secretData: [UUID: KeyData]
    
    public init() {
        self.keys = [:]
        self.newKeys = [:]
        self.secretData = [:]
    }
}

public extension AuthenticationFile {
    
    var isConfigured: Bool {
        keys.contains(where: { $0.value.permission == .owner })
    }
    
    init(owner: Key, secret: KeyData) {
        assert(owner.permission == .owner)
        self.keys = [owner.id : owner]
        self.newKeys = [:]
        self.secretData = [owner.id : secret]
    }
}
