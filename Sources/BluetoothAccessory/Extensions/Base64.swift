//
//  Base64.swift
//  
//
//  Created by Alsey Coleman Miller on 4/6/23.
//

import Foundation

extension Data {
    /// Decodes a base64-url encoded string to data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public init?(base64URLEncoded: String, options: Data.Base64DecodingOptions = []) {
        self.init(base64Encoded: base64URLEncoded.base64URLUnescaped(), options: options)
    }

    /// Decodes base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public init?(base64URLEncoded: Data, options: Data.Base64DecodingOptions = []) {
        self.init(base64Encoded: base64URLEncoded.base64URLUnescaped(), options: options)
    }

    /// Encodes data to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    ///
    /// - parameter options: The options to use for the encoding. Default value is `[]`.
    /// - returns: The base64-url encoded string.
    public func base64URLEncodedString(options: Data.Base64EncodingOptions = []) -> String {
        return base64EncodedString(options: options).base64URLEscaped()
    }

    /// Encodes data to base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    ///
    /// - parameter options: The options to use for the encoding. Default value is `[]`.
    /// - returns: The base64-url encoded data.
    public func base64URLEncodedData(options: Data.Base64EncodingOptions = []) -> Data {
        return base64EncodedData(options: options).base64URLEscaped()
    }
}

/// MARK: String Escape
extension String {
    /// Converts a base64-url encoded string to a base64 encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLUnescaped() -> String {
        let replaced = replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = replaced.count % 4
        if padding > 0 {
            return replaced + String(repeating: "=", count: 4 - padding)
        } else {
            return replaced
        }
    }

    /// Converts a base64 encoded string to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLEscaped() -> String {
        return replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Converts a base64-url encoded string to a base64 encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLUnescape() {
        self = base64URLUnescaped()
    }

    /// Converts a base64 encoded string to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLEscape() {
        self = base64URLEscaped()
    }
}

/// MARK: Data Escape
extension Data {
    /// Converts base64-url encoded data to a base64 encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLUnescape() {
        for (i, byte) in enumerated() {
            switch byte {
            case .hyphen: self[i] = .plus
            case .underscore: self[i] = .forwardSlash
            default: break
            }
        }
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = count % 4
        if padding > 0 {
            self += Data(repeating: .equals, count: 4 - count % 4)
        }
    }

    /// Converts base64 encoded data to a base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLEscape() {
        for (i, byte) in enumerated() {
            switch byte {
            case .plus: self[i] = .hyphen
            case .forwardSlash: self[i] = .underscore
            default: break
            }
        }
        self = split(separator: .equals).first ?? .init()
    }

    /// Converts base64-url encoded data to a base64 encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLUnescaped() -> Data {
        var data = self
        data.base64URLUnescape()
        return data
    }

    /// Converts base64 encoded data to a base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLEscaped() -> Data {
        var data = self
        data.base64URLEscape()
        return data
    }
}

internal extension Data.Element {
    
        /// '\t'
        static let horizontalTab: UInt8 = 0x9

        /// '\n'
        static let newLine: UInt8 = 0xA

        /// '\r'
        static let carriageReturn: UInt8 = 0xD

        /// ' '
        static let space: UInt8 = 0x20

        /// !
        static let exclamation: UInt8 = 0x21

        /// "
        static let quote: UInt8 = 0x22

        /// #
        static let numberSign: UInt8 = 0x23

        /// $
        static let dollar: UInt8 = 0x24

        /// %
        static let percent: UInt8 = 0x25
        
        /// &
        static let ampersand: UInt8 = 0x26

        /// '
        static let apostrophe: UInt8 = 0x27

        /// (
        static let leftParenthesis: UInt8 = 0x28

        /// )
        static let rightParenthesis: UInt8 = 0x29

        /// *
        static let asterisk: UInt8 = 0x2A

        /// +
        static let plus: UInt8 = 0x2B

        /// ,
        static let comma: UInt8 = 0x2C

        /// -
        static let hyphen: UInt8 = 0x2D

        /// .
        static let period: UInt8 = 0x2E

        /// /
        static let forwardSlash: UInt8 = 0x2F

        /// \
        static let backSlash: UInt8 = 0x5C

        /// :
        static let colon: UInt8 = 0x3A

        /// ;
        static let semicolon: UInt8 = 0x3B

        /// =
        static let equals: UInt8 = 0x3D

        /// ?
        static let questionMark: UInt8 = 0x3F

        /// @
        static let at: UInt8 = 0x40

        /// [
        static let leftSquareBracket: UInt8 = 0x5B

        /// ]
        static let rightSquareBracket: UInt8 = 0x5D

        /// ^
        static let caret: UInt8 = 0x5E
        
        /// _
        static let underscore: UInt8 = 0x5F

        /// `
        static let backtick: UInt8 = 0x60
        
        /// ~
        static let tilde: UInt8 = 0x7E

        /// {
        static let leftCurlyBracket: UInt8 = 0x7B

        /// }
        static let rightCurlyBracket: UInt8 = 0x7D

        /// <
        static let lessThan: UInt8 = 0x3C

        /// >
        static let greaterThan: UInt8 = 0x3E

        /// |
        static let pipe: UInt8 = 0x7C
}
