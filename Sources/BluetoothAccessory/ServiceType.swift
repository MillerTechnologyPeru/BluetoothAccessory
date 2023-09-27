//
//  ServiceType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Service Type
public enum ServiceType: UInt16, Codable, CaseIterable, Sendable {
    
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
}

public extension UUID {
    
    init(service: ServiceType) {
        self.init(bluetoothAccessory: (0x0001, service.rawValue))
    }
}

public extension BluetoothUUID {
    
    init(service: ServiceType) {
        self.init(uuid: .init(service: service))
    }
}

public extension ServiceType {
    
    init?(uuid: BluetoothUUID) {
        guard let value = Self.allCases.first(where: { BluetoothUUID(service: $0) == uuid }) else {
            return nil
        }
        self = value
    }
}

// MARK: - CustomStringConvertible

extension ServiceType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .information:
            return "Information"
        case .authentication:
            return "Authentication"
        case .bridge:
            return "Bridge"
        case .serial:
            return "Serial"
        case .firmwareUpdate:
            return "Firmware Update"
        case .wiFiTransport:
            return "Wi-Fi Transport"
        case .threadTransport:
            return "Thread Transport"
        case .loRaTransport:
            return "LoRa Transport"
        case .battery:
            return "Battery"
        case .inverter:
            return "Inverter"
        case .solarPanel:
            return "Solar Panel"
        case .lightbulb:
            return "Lightbulb"
        case .switch:
            return "Switch"
        case .lock:
            return "Lock"
        case .outlet:
            return "Outlet"
        case .label:
            return "Label"
        case .thermostat:
            return "Thermostat"
        case .heaterCooler:
            return "Heater/Cooler"
        case .fan:
            return "Fan"
        case .airPurifier:
            return "Air Purifier"
        case .humidifierDehumidifier:
            return "Humidifier/Dehumidifier"
        case .valve:
            return "Valve"
        case .irrigationSystem:
            return "Irrigation System"
        case .motionSensor:
            return "Motion Sensor"
        case .occupancySensor:
            return "Occupancy Sensor"
        case .temperatureSensor:
            return "Temperature Sensor"
        case .humiditySensor:
            return "Humidity Sensor"
        case .smokeSensor:
            return "Smoke Sensor"
        case .lightSensor:
            return "Light Sensor"
        case .leakSensor:
            return "Leak Sensor"
        case .carbonDioxideSensor:
            return "Carbon Dioxide Sensor"
        case .carbonMonoxideSensor:
            return "Carbon Monoxide Sensor"
        case .airQualitySensor:
            return "Air Quality Sensor"
        case .camera:
            return "Camera"
        case .securitySystem:
            return "Security System"
        }
    }
}
