//
//  ServiceType.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
enum ServiceTypeAppEnum: UInt16, AppEnum, CaseIterable {
    
    // Information
    case information                = 0
    case authentication
    case bridge
    case serial
    case firmwareUpdate
    case wiFiTransport
    case threadTransport
    case loRaTransport
    
    // Energy
    case battery                    = 100
    case inverter
    case solarPanel
    
    // Actuator
    case lightbulb                  = 200
    case `switch`
    case lock
    case outlet
    case label
    
    // Climate
    case thermostat                 = 300
    case heaterCooler
    case fan
    
    // Air
    case airPurifier                = 400
    case humidifierDehumidifier
    
    // Water
    case valve                      = 500
    case irrigationSystem
    
    // Sensor
    case motionSensor               = 600
    case occupancySensor
    case temperatureSensor
    case humiditySensor
    case smokeSensor
    case lightSensor
    case leakSensor
    case carbonDioxideSensor
    case carbonMonoxideSensor
    case airQualitySensor
    
    // Security
    case camera                     = 700
    case securitySystem
    
    init(_ value: ServiceType) {
        self.init(rawValue: value.rawValue)!
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Service Type"
    }
    
    static var caseDisplayRepresentations: [ServiceTypeAppEnum : DisplayRepresentation] {
        [
            .information: "Information",
            .authentication: "Authentication",
            .bridge: "Bridge",
            .serial: "Serial",
            .firmwareUpdate: "Firmware Update",
            .wiFiTransport: "Wi-Fi Transport",
            .threadTransport: "Thread Transport",
            .loRaTransport: "LoRa Transport",
            .battery: "Battery",
            .inverter: "Inverter",
            .solarPanel: "Solar Panel",
            .lightbulb: "Lightbulb",
            .switch: "Switch",
            .lock: "Lock",
            .outlet: "Outlet",
            .label: "Label",
            .thermostat: "Thermostat",
            .heaterCooler: "Heater/Cooler",
            .fan: "Fan",
            .airPurifier: "Air Purifier",
            .humidifierDehumidifier: "Humidifier/Dehumidifier",
            .valve: "Valve",
            .irrigationSystem: "Irrigation System",
            .motionSensor: "Motion Sensor",
            .occupancySensor: "Occupancy Sensor",
            .temperatureSensor: "Temperature Sensor",
            .humiditySensor: "Humidity Sensor",
            .smokeSensor: "Smoke Sensor",
            .lightSensor: "Light Sensor",
            .leakSensor: "Leak Sensor",
            .carbonDioxideSensor: "Carbon Dioxide Sensor",
            .carbonMonoxideSensor: "Carbon Monoxide Sensor",
            .airQualitySensor: "Air Quality Sensor",
            .camera: "Camera",
            .securitySystem: "Security System"
        ]
    }
}
