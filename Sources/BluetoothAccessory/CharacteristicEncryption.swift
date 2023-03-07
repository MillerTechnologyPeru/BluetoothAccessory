//
//  CharacteristicEncryption.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

/// Characteristic Encryption
public enum CharacteristicEncryption: UInt8, Codable, CaseIterable {
    
    /// Normal GATT read or write, ideal for small values.
    case `none`
    
    /// Authentication and encrypted data, ideal for small values. Read or write.
    case encryptedData
    
    /// Authentication and encryped data partitioned in chunks. Read or write. Data type must be TLV8.
    case encryptedList
}
