//
//  CharacteristicFormat.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import TLVCoding

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

/// Characteristic Value
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

public extension CharacteristicValue {
    
    /// Characteristic format.
    var format: CharacteristicFormat {
        switch self {
        case .tlv8:
            return .tlv8
        case .string:
            return .string
        case .data:
            return .data
        case .date:
            return .date
        case .uuid:
            return .uuid
        case .bool:
            return .bool
        case .int8:
            return .int8
        case .int16:
            return .int16
        case .int32:
            return .int32
        case .int64:
            return .int64
        case .uint8:
            return .uint8
        case .uint16:
            return .uint16
        case .uint32:
            return .uint32
        case .uint64:
            return .uint64
        case .float:
            return .float
        case .double:
            return .double
        }
    }
}

// MARK: - CharacteristicCodable

public protocol CharacteristicCodable {
    
    static var characteristicFormat: CharacteristicFormat { get }
    
    var characteristicValue: CharacteristicValue { get }
    
    init?(characteristicValue: CharacteristicValue)
}

public extension CharacteristicCodable where Self: RawRepresentable, Self.RawValue: CharacteristicCodable {
    
    static var characteristicFormat: CharacteristicFormat { RawValue.characteristicFormat }
    
    var characteristicValue: CharacteristicValue { rawValue.characteristicValue }
    
    init?(characteristicValue: CharacteristicValue) {
        guard let rawValue = RawValue(characteristicValue: characteristicValue) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
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

extension UInt32: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .uint32 }
    
    public var characteristicValue: CharacteristicValue { .uint32(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .uint32(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension UInt64: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .uint64 }
    
    public var characteristicValue: CharacteristicValue { .uint64(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .uint64(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Int8: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .int8 }
    
    public var characteristicValue: CharacteristicValue { .int8(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .int8(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Int16: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .int16 }
    
    public var characteristicValue: CharacteristicValue { .int16(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .int16(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Int32: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .int32 }
    
    public var characteristicValue: CharacteristicValue { .int32(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .int32(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Int64: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .int64 }
    
    public var characteristicValue: CharacteristicValue { .int64(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .int64(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Float: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .float }
    
    public var characteristicValue: CharacteristicValue { .float(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .float(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

extension Double: CharacteristicCodable {
    
    public static var characteristicFormat: CharacteristicFormat { .double }
    
    public var characteristicValue: CharacteristicValue { .double(self) }
    
    public init?(characteristicValue: CharacteristicValue) {
        guard case let .double(value) = characteristicValue else {
            return nil
        }
        self = value
    }
}

// MARK: - Data

public extension CharacteristicValue {
    
    init?(from data: Data, format: CharacteristicFormat) {
        func decode<T: Decodable>(_ type: T.Type) -> T? {
            try? TLVDecoder.bluetoothAccessory.decode(type, from: Data([0, UInt8(data.count)]) + data)
        }
        switch format {
        case .tlv8:
            self = .tlv8(data)
        case .data:
            self = .data(data)
        case .string:
            guard let value = decode(String.self) else {
                return nil
            }
            self = .string(value)
        case .date:
            guard let value = decode(Date.self) else {
                return nil
            }
            self = .date(value)
        case .uuid:
            guard let value = decode(UUID.self) else {
                return nil
            }
            self = .uuid(value)
        case .bool:
            guard let value = decode(Bool.self) else {
                return nil
            }
            self = .bool(value)
        case .int8:
            guard let value = decode(Int8.self) else {
                return nil
            }
            self = .int8(value)
        case .int16:
            guard let value = decode(Int16.self) else {
                return nil
            }
            self = .int16(value)
        case .int32:
            guard let value = decode(Int32.self) else {
                return nil
            }
            self = .int32(value)
        case .int64:
            guard let value = decode(Int64.self) else {
                return nil
            }
            self = .int64(value)
        case .uint8:
            guard let value = decode(UInt8.self) else {
                return nil
            }
            self = .uint8(value)
        case .uint16:
            guard let value = decode(UInt16.self) else {
                return nil
            }
            self = .uint16(value)
        case .uint32:
            guard let value = decode(UInt32.self) else {
                return nil
            }
            self = .uint32(value)
        case .uint64:
            guard let value = decode(UInt64.self) else {
                return nil
            }
            self = .uint64(value)
        case .float:
            guard let value = decode(Float.self) else {
                return nil
            }
            self = .float(value)
        case .double:
            guard let value = decode(Double.self) else {
                return nil
            }
            self = .double(value)
        }
    }
    
    func encode() -> Data {
        func encode<T: Encodable>(_ value: T) throws -> Data {
            try TLVEncoder.bluetoothAccessory.encode([value]).suffix(from: 2)
        }
        switch self {
        case .tlv8(let data):
            return data
        case .data(let data):
            return data
        case .string(let string):
            return try! encode(string)
        case .date(let date):
            return try! encode(date)
        case .uuid(let uuid):
            return try! encode(uuid)
        case .bool(let bool):
            return try! encode(bool)
        case .int8(let value):
            return try! encode(value)
        case .int16(let value):
            return try! encode(value)
        case .int32(let value):
            return try! encode(value)
        case .int64(let value):
            return try! encode(value)
        case .uint8(let value):
            return try! encode(value)
        case .uint16(let value):
            return try! encode(value)
        case .uint32(let value):
            return try! encode(value)
        case .uint64(let value):
            return try! encode(value)
        case .float(let float):
            return try! encode(float)
        case .double(let double):
            return try! encode(double)
        }
    }
}
