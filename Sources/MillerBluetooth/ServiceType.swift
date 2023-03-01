//
//  ServiceType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Service Type
public enum ServiceType: UInt16, CaseIterable {
    
    // Information
    case information
    case bridge
    case serial
    case firmwareUpdate
    case wiFiTransport
    case threadTransport
    case loraTransport
    
    // Energy
    case battery                    = 100
    case inverter
    case solarPanel
    
    // Actuator
    case lightbulb                  = 200
    case `switch`
    case lock
    case outlet
    case valve
    case label
    
    // Air
    case thermostat                 = 300
    case fan
    case airPurifier
    case humidifierDehumidifier
    case heaterCooler
    case irrigationSystem
    
    // Sensor
    case motionSensor               = 400
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
    case camera                     = 500
    case securitySystem
}

public extension UUID {
    
    init(service: ServiceType) {
        self.init(uuidString: "650135C4-45D6-4A00-B240-DF6FE201" + service.rawValue.toHexadecimal())!
    }
}

public extension BluetoothUUID {
    
    init(service: ServiceType) {
        self.init(uuid: .init(service: service))
    }
}
