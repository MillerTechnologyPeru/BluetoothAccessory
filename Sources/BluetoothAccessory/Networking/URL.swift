//
//  URL.swift
//
//
//  Created by Alsey Coleman Miller on 2/29/23.
//

import Foundation

/// Accessory Custom URL scheme
public enum AccessoryURL: Equatable, Hashable {
    
    /// View the specified accessory details
    case accessory(UUID)
    
    /// Setup the accessory with the provided secret
    case setup(UUID, KeyData)
    
    /// Accept the new key invitation
    case newKey(NewKey.Invitation)
}

public extension AccessoryURL {
    
    static var scheme: String { "bluetooth-accessory" }
}

internal extension AccessoryURL {
    
    static let encoder = JSONEncoder()
    
    static let decoder = JSONDecoder()
    
    var type: URLType {
        switch self {
        case .setup: return .setup
        case .newKey: return .newKey
        case .accessory: return .accessory
        }
    }
    
    enum URLType: String {
        
        case accessory
        case setup
        case newKey = "newkey"
        
        var componentsCount: Int {
            switch self {
            case .setup:
                return 3
            case .newKey:
                return 2
            case .accessory:
                return 2
            }
        }
    }
}

// MARK: - RawRepresentable

extension AccessoryURL: RawRepresentable {
    
    public init?(rawValue: String) {
        guard let url = URL(string: rawValue) else {
            return nil
        }
        self.init(url: url)
    }
    
    public var rawValue: String {
        URL(self).absoluteString
    }
}

// MARK: - CustomStringConvertible

extension AccessoryURL: CustomStringConvertible {
    
    public var description: String {
        rawValue
    }
}

// MARK: - URL

public extension URL {
    
    init(_ accessoryURL: AccessoryURL) {
        
        let type = accessoryURL.type
        var path = [String]()
        path.reserveCapacity(type.componentsCount)
        path.append(type.rawValue)
        switch accessoryURL {
        case let .setup(accessoryIdentifier, secretData):
            path.append(accessoryIdentifier.uuidString)
            path.append(secretData.data.base64URLEncodedString())
        case let .newKey(newKey):
            let data = try! AccessoryURL.encoder.encode(newKey)
            let base64 = data.base64URLEncodedString()
            path.append(base64)
        case let .accessory(accessoryIdentifier):
            path.append(accessoryIdentifier.uuidString)
        }
        var components = URLComponents()
        components.scheme = AccessoryURL.scheme
        components.path = path.reduce("", { $0 + "/" + $1 })
        guard let url = components.url
            else { fatalError("Could not compose URL") }
        self = url
    }
}

public extension AccessoryURL {
    
    init?(url: URL) {
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        guard url.scheme == AccessoryURL.scheme,
            let type = pathComponents.first.flatMap({ URLType(rawValue: $0.lowercased()) }),
            pathComponents.count == type.componentsCount
            else { return nil }
        
        switch type {
        case .setup:
            guard let accessoryIdentifier = UUID(uuidString: pathComponents[1]),
                let secretBase64 = Data(base64URLEncoded: pathComponents[2]),
                let secret = KeyData(data: secretBase64)
                else { return nil }
            self = .setup(accessoryIdentifier, secret)
        case .newKey:
            guard let data = Data(base64URLEncoded: pathComponents[1]),
                  let invitation = try? AccessoryURL.decoder.decode(NewKey.Invitation.self, from: data)
                else { return nil }
            self = .newKey(invitation)
        case .accessory:
            guard let accessoryIdentifier = UUID(uuidString: pathComponents[1])
                else { return nil }
            self = .accessory(accessoryIdentifier)
        }
    }
    
    /// Initialize from Web URL
    init?(web url: URL) {
        switch url.scheme {
        case "https":
            guard let url = URL(string: AccessoryURL.scheme + ":" + url.path) else {
                return nil
            }
            self.init(url: url)
        case AccessoryURL.scheme:
            self.init(url: url)
        default:
            return nil
        }
    }
}
