//
//  CharacteristicUnit.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

/// Characteristic Unit
public enum CharacteristicUnit: UInt8, Codable, CaseIterable {
    
    case arcdegrees
    case celsius
    case fahrenheit
    case lux
    case microgramsPerMCubed
    case percentage
    case ppm
    case seconds
    case watts
    case amps
    case volts
    case hertz
}
