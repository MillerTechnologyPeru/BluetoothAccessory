//
//  KeyCredentials.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

public struct Credentials: Equatable {
    
    public let id: UUID
    
    public let secret: KeyData
    
    public init(id: UUID, secret: KeyData) {
        self.id = id
        self.secret = secret
    }
}
