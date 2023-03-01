//
//  BuildVersion.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

public struct BuildVersion: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt64
    
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
}

// MARK: - CustomStringConvertible

extension BuildVersion: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description
    }
}
