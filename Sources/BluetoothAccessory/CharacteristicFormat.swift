//
//  CharacteristicFormat.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

/// Characteristic Format
public enum CharacteristicFormat: UInt8, Codable, CaseIterable {
    
    case tlv8
    case string
    case data
    case date
    case uuid
    case bool
    case int8
    case int16
    case int32
    case int64
    case uint8
    case uint16
    case uint32
    case uint64
    case float
    case double
}
