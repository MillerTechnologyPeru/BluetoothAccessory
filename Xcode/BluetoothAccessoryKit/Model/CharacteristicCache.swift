//
//  CharacteristicCache.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import BluetoothAccessory

/// Cache of discovered characteristics
public struct CharacteristicCache: Equatable, Hashable, Codable {
    
    public let service: BluetoothUUID
    
    public let metadata: CharacteristicMetadata
    
    public var value: Value?
}

// MARK: - Identifiable

extension CharacteristicCache: Identifiable {
    
    public var id: String {
        service.description + "/" + metadata.type.description
    }
}

// MARK: - Supporting Types

public extension CharacteristicCache {
    
    /// Cached characteristic value.
    enum Value: Equatable, Hashable, Codable {
        
        case single(CharacteristicValue)
        case list([CharacteristicValue])
    }
}
