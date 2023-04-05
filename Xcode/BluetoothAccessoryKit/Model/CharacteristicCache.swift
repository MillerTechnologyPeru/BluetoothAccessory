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
    
    /// Accessory identifier
    public let accessory: UUID
    
    /// Characteristic service
    public let service: BluetoothUUID
    
    /// Characteristic metadata
    public let metadata: CharacteristicMetadata
    
    /// Characteristic cached value
    public var value: Value?
    
    /// Date characteristic was last read or written.
    public var updated: Date
}

// MARK: - Identifiable

extension CharacteristicCache: Identifiable {
    
    internal static func id(accessory: UUID, service: BluetoothUUID, characteristic: BluetoothUUID) -> String {
        accessory.uuidString + "/" + service.rawValue + "/" + characteristic.rawValue
    }
    
    public var id: String {
        return CharacteristicCache.id(accessory: accessory, service: service, characteristic: metadata.type)
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

// MARK: - ExpressibleByBooleanLiteral

extension CharacteristicCache.Value: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        self = .single(.bool(value))
    }
}

// MARK: - ExpressibleByStringLiteral

extension CharacteristicCache.Value: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self = .single(.string(value))
    }
}
