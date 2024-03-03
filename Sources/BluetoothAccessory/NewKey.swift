//
//  NewKey.swift
//
//
//  Created by Alsey Coleman Miller on 8/13/18.
//

import Foundation

/// New Key
public struct NewKey: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    /// The unique identifier of the key.
    public let id: UUID
    
    /// The owner of the key.
    public let user: UUID
    
    /// Key's permissions.
    public let permission: Permission
    
    /// Date new key invitation was created.
    public let created: Date
    
    /// Expiration date for new key invitation.
    public let expiration: Date
    
    public init(id: UUID = UUID(),
                user: UUID,
                permission: Permission = .anytime,
                created: Date = Date(),
                expiration: Date = Date().addingTimeInterval(60 * 60 * 24)) {
        
        self.id = id
        self.user = user
        self.permission = permission
        self.created = created
        self.expiration = expiration
    }
}

public extension NewKey {
    
    /// Exportable new key invitation.
    struct Invitation: Codable, Equatable, Hashable {
        
        /// Identifier of target device.
        public let device: UUID
        
        /// New Key to create.
        public let key: NewKey
        
        /// Temporary shared secret to accept the key invitation.
        public let secret: KeyData
        
        public init(device: UUID, key: NewKey, secret: KeyData) {
            
            self.device = device
            self.key = key
            self.secret = secret
        }
    }
}

extension NewKey.Invitation: Identifiable {
    
    public var id: String {
        return device.description + "-" + key.id.description
    }
}

internal extension Key {
    
    init(_ newKey: NewKey) {
        self.init(
            id: newKey.id,
            user: newKey.user,
            created: newKey.created,
            permission: newKey.permission
        )
    }
}

public extension NewKey {
    
    func confirm() -> Key {
        Key(
            id: id,
            user: user,
            created: created,
            permission: permission
        )
    }
}
