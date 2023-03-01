//
//  AuthenticationError.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

public enum AuthenticationError: Error {
    
    /// Invalid authentication HMAC signature.
    case invalidAuthentication
    
    /// Could not decrypt value.
    case decryptionError(Error)
    
    /// Could not encrypt value.
    case encryptionError(Error)
}
