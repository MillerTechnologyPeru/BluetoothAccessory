//
//  RemoveKeyCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/23/23.
//

import Foundation
import Bluetooth
import GATT

/// Remove Key Characteristic
public struct RemoveKeyCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
    
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .removeKey) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.write, .encrypted] }
    
    public init(value: RemoveKeyRequest) {
        self.value = value
    }
    
    public var value: RemoveKeyRequest
}

// MARK: - Supporting Types

public struct RemoveKeyRequest: Equatable, Hashable, Codable {
    
    /// Key to remove.
    public let id: UUID
    
    /// Type of key
    public let type: KeyType
    
    public init(
        id: UUID,
        type: KeyType
    ) {
        self.id = id
        self.type = type
    }
}

extension RemoveKeyRequest: CharacteristicTLVCodable { }
