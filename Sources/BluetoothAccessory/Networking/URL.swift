//
//  URL.swift
//
//
//  Created by Alsey Coleman Miller on 2/29/23.
//

import Foundation

/// Accessory Custom URL scheme
public enum AccessoryURL: Equatable, Hashable {
    
    case setup(UUID, KeyData)
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
        }
    }
    
    enum URLType: String {
        
        case setup
        case newKey = "newkey"
        
        var componentsCount: Int {
            switch self {
            case .setup:
                return 3
            case .newKey:
                return 2
            }
        }
    }
}

// MARK: - RawRepresentable

extension AccessoryURL: RawRepresentable {
    
    public init?(rawValue url: URL) {
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        guard url.scheme == Swift.type(of: self).scheme,
            let type = pathComponents.first.flatMap({ URLType(rawValue: $0.lowercased()) }),
            pathComponents.count == type.componentsCount
            else { return nil }
        
        switch type {
        case .setup:
            guard let accessoryIdentifier = UUID(uuidString: pathComponents[1]),
                let secretBase64 = Data(base64Encoded: pathComponents[2]),
                let secret = KeyData(data: secretBase64)
                else { return nil }
            self = .setup(accessoryIdentifier, secret)
        case .newKey:
            guard let data = Data(base64Encoded: pathComponents[1]),
                  let invitation = try? Self.decoder.decode(NewKey.Invitation.self, from: data)
                else { return nil }
            self = .newKey(invitation)
        }
    }
    
    public var rawValue: URL {
        
        let type = self.type
        var path = [String]()
        path.reserveCapacity(type.componentsCount)
        path.append(type.rawValue)
        switch self {
        case let .setup(accessoryIdentifier, secretData):
            path.append(accessoryIdentifier.uuidString)
            path.append(secretData.data.base64EncodedString())
        case let .newKey(newKey):
            let data = try! Self.encoder.encode(newKey)
            let base64 = data.base64EncodedString()
            path.append(base64)
        }
        var components = URLComponents()
        components.scheme = Swift.type(of: self).scheme
        components.path = path.reduce("", { $0 + "/" + $1 })
        guard let url = components.url
            else { fatalError("Could not compose URL") }
        return url
    }
}
