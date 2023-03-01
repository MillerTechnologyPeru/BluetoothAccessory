//
//  CharacteristicEncryption.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

/// Characteristic Encryption
public enum CharacteristicEncryption: UInt8, Codable, CaseIterable {
    
    case `none`
    case authentication
    case encryptedData
    case encryptedChunks
}
