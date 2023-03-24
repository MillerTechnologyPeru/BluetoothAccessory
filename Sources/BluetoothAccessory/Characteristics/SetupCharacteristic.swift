//
//  SetupCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

/// Setup Characteristic
public struct SetupCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .setup) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: SetupRequest) {
        self.value = value
    }
    
    public var value: SetupRequest
}

// MARK: - Supporting Types

public struct SetupRequest: Equatable, Hashable, Codable {
    
    /// Key identifier
    public let id: UUID
    
    /// Key secret
    public let secret: KeyData
    
    public init(id: UUID = UUID(),
                secret: KeyData = KeyData()) {
        
        self.id = id
        self.secret = secret
    }
}

extension SetupRequest: CharacteristicTLVCodable { }

public extension Key {
    
    /// Initialize a new owner key from a setup request.
    init(setup: SetupRequest) {
        
        self.init(
            id: setup.id,
            name: "Owner",
            created: Date(),
            permission: .owner
        )
    }
}
