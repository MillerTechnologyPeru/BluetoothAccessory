//
//  AccessoryType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

/// Accessory Type
public enum AccessoryType: UInt16, Codable {
    
    case other
    case bridge
    case fan
    case garageDoorOpener
    case lightbulb
    case doorLock
    case outlet
    case inverter
    case `switch`
    case thermostat
    case sensor
    case securitySystem
    case door
    case window
    case windowCovering
    case programmableSwitch
    case rangeExtender
    case ipCamera
    case videoDoorbell
    case airPurifier
    case airHeater
    case airConditioner
    case airHumidifier
    case airDehumidifier
    case speaker
    case airport
    case sprinkler
    case faucet
    case showerHead
    case television
    case targetController
    case wiFiRouter
    case audioReceiver
    case televisionSetTopBox
    case televisionStreamingStick
}
