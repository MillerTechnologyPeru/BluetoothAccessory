//
//  CharacteristicUnit.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 4/6/23.
//

import Foundation
import BluetoothAccessory

public extension CharacteristicUnit {
    
    func description(for value: CharacteristicValue) -> String {
        value.description + symbol
    }
    
    var symbol: String {
        switch self {
        case .arcdegrees:
            return "°"
        case .celsius:
            return "°C"
        case .lux:
            return "lx"
        case .microgramsPerMCubed:
            return "µg/m3"
        case .percentage:
            return "%"
        case .ppm:
            return "ppm"
        case .seconds:
            return "s"
        case .watts:
            return "W"
        case .amps:
            return "A"
        case .volts:
            return "V"
        case .hertz:
            return "Hz"
        case .meters:
            return "m"
        }
    }
}
