//
//  AccessoryType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

/// Accessory Type
public enum AccessoryType: UInt16, Codable, CaseIterable {
    
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

// MARK: - CustomStringConvertible

extension AccessoryType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .other: return "Other"
        case .bridge: return "Bridge"
        case .fan: return "Fan"
        case .garageDoorOpener: return "Garage Door Opener"
        case .lightbulb: return "Lightbulb"
        case .doorLock: return "Door Lock"
        case .outlet: return "Outlet"
        case .inverter: return "Inverter"
        case .`switch`: return "Switch"
        case .thermostat: return "Thermostat"
        case .sensor: return "Sensor"
        case .securitySystem: return "Security System"
        case .door: return "Door"
        case .window: return "Window"
        case .windowCovering: return "Window Covering"
        case .programmableSwitch: return "Programmable Switch"
        case .rangeExtender: return "Range Extender"
        case .ipCamera: return "IP Camera"
        case .videoDoorbell: return "Video Doorbell"
        case .airPurifier: return "Air Purifier"
        case .airHeater: return "Air Heater"
        case .airConditioner: return "Air Conditioner"
        case .airHumidifier: return "Air Humidifier"
        case .airDehumidifier: return "Air Dehumidifier"
        case .speaker: return "Speaker"
        case .sprinkler: return "Sprinkler"
        case .faucet: return "Faucet"
        case .showerHead: return "Shower Head"
        case .television: return "Television"
        case .targetController: return "Target Controller"
        case .wiFiRouter: return "Wi-Fi Router"
        case .audioReceiver: return "Audio Receiver"
        case .televisionSetTopBox: return "Television Set Top Box"
        case .televisionStreamingStick: return "Television Streaming Stick"
        }
    }
}
