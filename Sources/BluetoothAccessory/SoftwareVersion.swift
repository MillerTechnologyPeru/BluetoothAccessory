//
//  SoftwareVersion.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import TLVCoding

public struct SoftwareVersion: Equatable, Hashable {
    
    public var major: UInt8
    
    public var minor: UInt8
    
    public var patch: UInt8
    
    public init(major: UInt8, minor: UInt8, patch: UInt8) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

// MARK: - Definitions

public extension SoftwareVersion {
    
    static var current: SoftwareVersion { return SoftwareVersion(major: 1, minor: 0, patch: 0) }
}

// MARK: - RawRepresentable

extension SoftwareVersion: RawRepresentable {
    
    private static let separator: Character = "."
    
    public init?(rawValue: String) {
        let components = rawValue.split(separator: type(of: self).separator)
        guard components.count == 3,
            let major = UInt8(components[0]),
            let minor = UInt8(components[1]),
            let patch = UInt8(components[2])
            else { return nil }
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public var rawValue: String {
        return "\(major).\(minor).\(patch)"
    }
}

// MARK: - CustomStringConvertible

extension SoftwareVersion: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

// MARK: - Codable

extension SoftwareVersion: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = SoftwareVersion(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid string value \(rawValue)")
        }
        self = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - TLVCodable

extension SoftwareVersion: TLVCodable {
    
    internal static var length: Int { return 3 }
    
    public init?(tlvData: Data) {
        guard tlvData.count == SoftwareVersion.length
             else { return nil }
        self.major = tlvData[0]
        self.minor = tlvData[1]
        self.patch = tlvData[2]
    }
    
    public var tlvData: Data {
        return Data([major, minor, patch])
    }
}
