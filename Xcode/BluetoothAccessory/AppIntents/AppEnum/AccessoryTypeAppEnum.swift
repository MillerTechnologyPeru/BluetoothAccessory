//
//  AccessoryType.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
enum AccessoryTypeAppEnum: UInt16, AppEnum, CaseIterable {
    
    case other
    case bridge
    case fan
    case garageDoorOpener
    case lightbulb
    case doorLock
    case outlet
    case inverter
    case generator
    case solarPanel
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
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Accessory Type"
    }
    
    static var caseDisplayRepresentations: [AccessoryTypeAppEnum : DisplayRepresentation] {
        [
            .other: "Other",
            .bridge: "Bridge",
            .fan: "Fan",
            .garageDoorOpener: "Garage Door Opener",
            .lightbulb: "Lightbulb",
            .doorLock: "Door Lock",
            .outlet: "Outlet",
            .inverter: "Inverter",
            .generator: "Generator",
            .solarPanel: "Solar Panel",
            .`switch`: "Switch",
            .thermostat: "Thermostat",
            .sensor: "Sensor",
            .securitySystem: "Security System",
            .door: "Door",
            .window: "Window",
            .windowCovering: "Window Covering",
            .programmableSwitch: "Programmable Switch",
            .rangeExtender: "Range Extender",
            .ipCamera: "IP Camera",
            .videoDoorbell: "Video Doorbell",
            .airPurifier: "Air Purifier",
            .airHeater: "Air Heater",
            .airConditioner: "Air Conditioner",
            .airHumidifier: "Air Humidifier",
            .airDehumidifier: "Air Dehumidifier",
            .speaker: "Speaker",
            .sprinkler: "Sprinkler",
            .faucet: "Faucet",
            .showerHead: "Shower Head",
            .television: "Television",
            .targetController: "Target Controller",
            .wiFiRouter: "Wi-Fi Router",
            .audioReceiver: "Audio Receiver",
            .televisionSetTopBox: "Television Set Top Box",
            .televisionStreamingStick: "Television Streaming Stick"
        ]
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryTypeAppEnum {
    
    init(_ value: AccessoryType) {
        self.init(rawValue: value.rawValue)!
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryType {
    
    init(_ value: AccessoryTypeAppEnum) {
        self.init(rawValue: value.rawValue)!
    }
}
