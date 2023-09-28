//
//  CharacteristicUnitAppEnum.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
enum CharacteristicUnitAppEnum: UInt8, AppEnum, CaseIterable {
    
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
    case meters
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Characteristic Unit"
    }
    
    static var caseDisplayRepresentations: [CharacteristicUnitAppEnum : DisplayRepresentation] {
        [
            .arcdegrees: "Arc Degrees",
            .celsius: "Celsius",
            .fahrenheit: "Fahrenheit",
            .lux: "Lux",
            .microgramsPerMCubed: "Micrograms Per Cubic Meter",
            .percentage: "Percentage",
            .ppm: "PPM",
            .seconds: "Seconds",
            .watts: "Watts",
            .amps: "Amperes",
            .volts: "Volts",
            .hertz: "Hertz",
            .meters: "Meters"
        ]
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicUnitAppEnum {
    
    init(_ value: CharacteristicUnit) {
        self.init(rawValue: value.rawValue)!
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicUnit {
    
    init(_ value: CharacteristicUnitAppEnum) {
        self.init(rawValue: value.rawValue)!
    }
}
