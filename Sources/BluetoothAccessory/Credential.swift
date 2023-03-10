//
//  KeyCredentials.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

public struct Credential: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UUID
    
    public let secret: KeyData
    
    public init(id: UUID, secret: KeyData) {
        self.id = id
        self.secret = secret
    }
}
