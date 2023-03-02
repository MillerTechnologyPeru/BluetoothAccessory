//
//  CharacteristicFormat.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

/// Characteristic Format
public enum CharacteristicFormat: UInt8, Codable, CaseIterable {
    
    case tlv8
    case string
    case data
    case date
    case uuid
    case bool
    case int8
    case int16
    case int32
    case int64
    case uint8
    case uint16
    case uint32
    case uint64
    case float
    case double
}

public enum CharacteristicValue: Equatable, Hashable {
    
    case tlv8(Data)
    case string(String)
    case data(Data)
    case date(Date)
    case uuid(UUID)
    case bool(Bool)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    case float(Float)
    case double(Double)
}

// MARK: -

public protocol CharacteristicCodable {
    
    static var characteristicFormat: CharacteristicFormat { get }
    
    var characteristicValue: CharacteristicValue { get }
    
    init?(characteristicValue: CharacteristicValue)
}

extension String: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .string }
    
    public var characteristicValue: CharacteristicValue { .string(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .string(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Data: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .data }
    
    public var characteristicValue: CharacteristicValue { .data(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .data(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Date: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .date }
    
    public var characteristicValue: CharacteristicValue { .date(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .date(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension UUID: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .uuid }
    
    public var characteristicValue: CharacteristicValue { .uuid(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .uuid(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Bool: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .bool }
    
    public var characteristicValue: CharacteristicValue { .bool(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .bool(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension UInt8: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .uint8 }
    
    public var characteristicValue: CharacteristicValue { .uint8(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .uint8(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension UInt16: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .uint16 }
    
    public var characteristicValue: CharacteristicValue { .uint16(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .uint16(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

// TODO: all codable types
