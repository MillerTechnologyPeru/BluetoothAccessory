//
//  Key.swift
//  
//
//  Created by Alsey Coleman Miller on 8/11/18.
//

import Foundation
import TLVCoding

/// A key accessing an accessory.
public struct Key: Identifiable, Codable, Equatable, Hashable, Sendable {
    
    /// The unique identifier of the key.
    public let id: UUID
    
    /// The owner of the key.
    public let user: UUID
    
    /// Date key was created.
    public let created: Date
    
    /// Key's permissions. 
    public let permission: Permission
    
    public init(
        id: UUID = UUID(),
        user: UUID,
        created: Date = Date(),
        permission: Permission
    ) {
        self.id = id
        self.user = user
        self.created = created
        self.permission = permission
    }
}

public extension Key {
    
    /// Setup Key
    static var setup: UUID { .zero }
}

// MARK: - Supporting Types

public enum KeyType: UInt8, CaseIterable {
    
    case key        = 0x00
    case newKey     = 0x01
}

internal extension KeyType {
    
    init?(stringValue: String) {
        guard let value = type(of: self).allCases.first(where: { $0.stringValue == stringValue })
            else { return nil }
        self = value
    }
    
    var stringValue: String {
        switch self {
        case .key: return "key"
        case .newKey: return "newKey"
        }
    }
}

// MARK: - CustomStringConvertible

extension KeyType: CustomStringConvertible {
    
    public var description: String {
        return stringValue
    }
}

// MARK: - Codable

extension KeyType: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = KeyType(stringValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid string value \(rawValue)")
        }
        self = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

// MARK: - TLVCodable

extension KeyType: TLVCodable {
    
    public init?(tlvData: Data) {
        guard tlvData.count == 1
            else { return nil }
        self.init(rawValue: tlvData[0])
    }
    
    public var tlvData: Data {
        return Data([rawValue])
    }
}
