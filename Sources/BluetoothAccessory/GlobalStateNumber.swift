//
//  GlobalStateNumber.swift
//
//
//  Created by Alsey Coleman Miller  on 3/2/24.
//

/// Global State Number
public struct GlobalStateNumber: RawRepresentable, Equatable, Hashable, Codable, Sendable {
    
    public var rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

// MARK: - Constants

public extension GlobalStateNumber {
    
    static var setup: GlobalStateNumber {
        0x00
    }
}

// MARK: - Methods

public extension GlobalStateNumber {
    
    func incremented() -> GlobalStateNumber {
        if rawValue == .max {
            return 0x01
        } else {
            return GlobalStateNumber(rawValue: rawValue + 1)
        }
    }
    
    mutating func increment() {
        self = incremented()
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension GlobalStateNumber: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}
