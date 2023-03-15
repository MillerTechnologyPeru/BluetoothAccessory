//
//  CharacteristicType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Accessory Characteristic Type
public enum CharacteristicType: UInt16, Codable, CaseIterable {
    
    // Information
    
    /// The unique identifier of the accessory.
    case identifier                         = 0
    
    /// Accessory Type
    case accessoryType
    
    /// The name of the accessory.
    case name
    
    /// A control you can use to ask the accessory to identify itself.
    case identify
    
    /// The model of the accessory.
    case model
    
    /// The manufacturer of the accessory.
    case manufacturer
    
    /// The serial number of the accessory.
    case serialNumber
    
    /// The version of the accessory.
    case version
    
    /// The software version of the accessory.
    case softwareVersion
    
    /// The hardware version of the accessory.
    case hardwareRevision
    
    /// The firmware version of the accessory.
    case firmwareVersion
    
    /// Vendor-specific product data.
    case productData
    
    /// Customizable Accessory name
    case configuredName
    
    case accessoryFlags
    
    /// An indicator of whether the accessory accepts only administrator access.
    case administratorOnlyAccess
    
    /// 
    case stagedFirmwareVersion
    
    /// An indicator of whether the service is working.
    case statusActive
    
    /// An indicator of whether the accessory has experienced a fault.
    case statusFault
    
    /// An indicator of whether an accessory has been tampered with.
    case statusTampered
    
    /// The current status of an accessory.
    case active
    
    /// The current usage state of an accessory.
    case inUse
    
    /// The configuration state of an accessory.
    case isConfigured
    
    ///
    case activeIdentifier
    case activityInterval
    case applicationMatchingIdentifier
    
    case assetUpdateReadiness
    
    /// Log data for the accessory.
    case logs
    
    // Authentication
    
    /// Writable Setup / Pairing characteristic
    case setup                              = 100
    
    /// Writable characteristic for encrypted reads.
    case encryptedRead
    
    /// Hash used for cryptographic operations
    case cryptoHash
    
    // Light
    
    /// The brightness of a light.
    case brightness                         = 200
    
    /// The color temperature of a light.
    case colorTemperature
    
    /// The current light level.
    case currentLightLevel
    
    /// The hue of the color used by a light.
    case hue
    
    /// The saturation of the color used by a light.
    case saturation

    // Battery
    
    /// The battery level of the accessory.
    case batteryLevel                       = 300
    
    /// The charging state of a battery.
    case chargingState
    
    /// Battery Type
    case batteryType
    
    /// A low battery indicator.
    case statusLowBattery
    
    /// Current charging current of battery in amperes.
    case batteryChargingCurrent
    
    /// Current voltage of battery.
    case batteryVoltage
    
    /// Whether the battery voltage is steady while charging.
    case batteryVoltageSteady
    case batteryRatingVoltage
    case batteryRechargeVoltage
    case batteryUnderVoltage
    case batteryBulkVoltage
    case batteryFloatVoltage
    
    // Outlet / Solar / Inverter
    
    /// The state of an outlet.
    case outletInUse                        = 400
    case outputVoltage
    case outputFrequency
    case outputApparentPower
    case outputActivePower
    case outputLoadPercent
    case outputSourcePriority
    
    /// The power state of the accessory.
    case powerState
    
    /// The state of a contact sensor.
    case contactSensorState
    
    /// The output state of a programmable switch.
    case programmableSwitchEvent
    
    /// The input event of a programmable switch.
    case programmableSwitchOutputState
    
    case inputVoltageRange
    case inverterHeatSinkTemperature
    case inverterBusVoltage
    case inverterChargerSourcePriority
    
    /// Inverter Device Mode
    case inverterMode
    
    case inverterOutputMode
    case inverterMaxParallel
    case solarInputCurrent
    case solarInputVoltage
    case gridVoltage
    case gridFrequency
    
    // Lock
    
    /// A control that accepts vendor-specific actions for lock management.
    case lockControlPoint                   = 500
    
    /// The current state of the locking mechanism.
    case lockCurrentState
    
    /// The last known action of the locking mechanism.
    case lockLastKnownAction
    
    /// The automatic timeout for a lockable accessory that supports automatic lockout.
    case lockManagementAutoSecurityTimeout
    
    /// The lock’s physical control state.
    case lockPhysicalControls
    
    /// The target state for the locking mechanism.
    case lockTargetState
    
    /// Lock Events
    case lockEvents
    
    // Door / Window
    
    /// The current door state.
    case currentDoorState                   = 600
    
    /// The target door state.
    case targetDoorState
    
    /// The current position of a door, window, awning, or window covering.
    case currentPosition
    
    /// The target position of a door, window, awning, or window covering.
    case targetPosition
    
    /// The position of an accessory like a door, window, awning, or window covering.
    case positionState
    
    /// An indicator of whether an accessory is jammed.
    case statusJammed
    
    /// A control for holding the position of an accessory like a door or window.
    case holdPosition
    
    /// The type of slat on an accessory like a window or a fan.
    case slatType
    
    /// The current state of slats on an accessory like a window or a fan.
    case currentSlatState

    // Tilting mechanisms
    
    /// The current tilt angle of a slat for an accessory like a window or a fan.
    case currentTiltAngle
    
    /// The target tilt angle of a slat for an accessory like a window or a fan.
    case targetTiltAngle
    
    /// The current tilt angle of a horizontal slat for an accessory like a window or a fan.
    case currentHorizontalTiltAngle
    
    /// The target tilt angle of a horizontal slat for an accessory like a window or a fan.
    case targetHorizontalTiltAngle
    
    /// The current tilt angle of a vertical slat for an accessory like a window or a fan.
    case currentVerticalTiltAngle
    
    /// The target tilt angle of a vertical slat for an accessory like a window or a fan.
    case targetVerticalTiltAngle
    
    // Temperature
    
    /// The current temperature measured by the accessory.
    case currentTemperature                 = 700
    
    /// The target temperature for the accessory to achieve.
    case targetTemperature
    
    /// The units of temperature currently active on the accessory.
    case temperatureDisplayUnits
    
    /// The target heating or cooling mode for a thermostat.
    case targetHeatingCoolingState
    
    /// The current heating or cooling mode for a thermostat.
    case currentHeatingCoolingState
    
    /// The target state for a device that heats or cools, like an oven or a refrigerator.
    case targetHeaterCoolerState
    
    /// The current state for a device that heats or cools, like an oven or a refrigerator.
    case currentHeaterCoolerState
    
    /// The temperature above which cooling will be active.
    case coolingThresholdTemperature
    
    /// The temperature below which heating will be active.
    case heatingThresholdTemperature
    
    // Humidity
    
    /// The current relative humidity measured by the accessory.
    case currentRelativeHumidity            = 800
    
    /// The target relative humidity for the accessory to achieve.
    case targetRelativeHumidity
    
    /// The current state of a humidifier or dehumidifier accessory.
    case currentHumidifierDehumidifierState
    
    /// The state that a humidifier or dehumidifier accessory should try to achieve.
    case targetHumidifierDehumidifierState
    
    /// The humidity below which a humidifier should begin to work.
    case relativeHumidityHumidifierThreshold
    
    /// The humidity above which a dehumidifier should begin to work.
    case relativeHumidityDehumidifierThreshold
    
    // Air Quality / Smoke Detection
    
    /// The air quality.
    case currentAirQuality                  = 900
    
    /// An indicator of abnormally high levels of carbon dioxide.
    case carbonDioxideDetected
    
    /// The measured carbon dioxide level.
    case carbonDioxideLevel
    
    /// The highest recorded level of carbon dioxide.
    case carbonDioxidePeakLevel
    
    /// An indicator of abnormally high levels of carbon monoxide.
    case carbonMonoxideDetected
    
    /// The measured carbon monoxide level.
    case carbonMonoxideLevel
    
    /// The highest recorded level of carbon monoxide.
    case carbonMonoxidePeakLevel
    
    /// The measured density of nitrogen dioxide.
    case nitrogenDioxideDensity
    
    /// The measured density of ozone.
    case ozoneDensity
    
    /// A smoke detection indicator.
    case smokeDetected
    
    /// The measured density of sulphur dioxide.
    ///
    /// The corresponding value is a number in units of micrograms per cubic meter.
    case sulphurDioxideDensity
    
    /// The measured density of air-particulate matter of size 10 micrograms.
    case pm10Density
    
    /// The measured density of air-particulate matter of size 2.5 micrograms.
    case pm25Density
    
    /// The measured density of volatile organic compounds.
    case volatileOrganicCompoundDensity
    
    // Fans
    
    /// The current state of a fan.
    case currentFanState                    = 1000
    
    /// The target state of a fan.
    case targetFanState
    
    /// The rotation direction of an accessory like a fan.
    case rotationDirection
    
    /// The rotation speed of an accessory like a fan.
    case rotationSpeed
    
    /// An indicator of whether a fan swings back and forth during operation.
    case swingMode
    
    // Purifiers and filters
    
    /// The current air purifier state.
    case currentAirPurifierState            = 1100
    
    /// The target air purifier state.
    case targetAirPurifierState
    
    /// The amount of useful life remaining in a filter.
    case filterLifeLevel
    
    /// A filter’s change indicator.
    case filterChangeIndication
    
    /// A reset control for a filter change notification.
    case filterResetChangeIndication
    
    // Water
    
    /// The water level measured by an accessory.
    case currentWaterLevel                  = 1200
    
    /// The type of automated valve that controls fluid flow.
    case valveType
    
    /// A leak detection indicator.
    case leakDetected
    
    // Security
    
    /// The alarm trigger state.
    case securitySystemAlarmType            = 1300
    
    /// The current security system state.
    case securitySystemCurrentState
    
    /// The target security system state.
    case securitySystemTargetState
    
    /// An indicator of whether an obstruction is detected, as when something prevents a garage door from closing.
    case obstructionDetected
    
    /// An indicator of whether the home is occupied.
    case occupancyDetected
    
    /// An indicator of whether the accessory has detected motion.
    case motionDetected
    
    // Audio / Video
    
    /// A control for muting audio.
    case mute                               = 1400
    
    /// An indicator of whether audio feedback, like a beep or other external sound mechanism, is enabled.
    case audioFeedback
    
    /// The input or output volume of an audio device.
    case volume
    case volumeControlType
    case volumeSelector
    case targetMediaState
    case currentMediaState
    case closedCaptions
    
    ///
    case pictureMode
    
    // Serial
    
    /// Writable Serial Console
    case serialConsoleInput                 = 1500
    
    /// Readable Serial Console
    case serialConsoleOutput
    
    // Radio
    case transmitPower                      = 1600
    case signalToNoiseRatio
    case ccaEnergyDetectThreshold
    case ccaSignalDetectThreshold
    case receivedSignalStrengthIndication
    case receiverSensitivity
    
    // Transport
    case currentTransport                   = 65000
    case setupTransferTransport
    case wiFiStatus
    case wiFiCapabilities
    case wiFiConfiguration
    case wiFiNetworkList
    case threadStatus
    case threadControlPoint
    case threadNodeCapabilities
    case threadOpenthreadVersion
    case loRaStatus
    
    // Other
    case currentVisibilityState
    case displayOrder
    case eventRetransmissionMaximum
    case eventTransmissionCounters
    case heartBeat
    
    case inputDeviceType
    case inputSourceType
    case labelIndex
    case labelNamespace
    case macRetransmissionMaximum
    case macTransmissionCounters
    case maximumTransmitPower
    case metricsBufferFullState
    
    case characteristicValueActiveTransitionCount
    case characteristicValueTransitionControl

    case operatingStateResponse
    
    case firmwareUpdateReadiness
    case firmwareUpdateStatus
    case hardwareFinish
    
    case ping
    case powerModeSelection
    case programMode
    case remainingDuration
    case remoteKey
    case selectedDiagnosticsModes
    case setDuration
    
    case sleepDiscoveryMode
    case sleepInterval
    case supportedAssetTypes
    case supportedCharacteristicValueTransitionConfiguration
    case supportedDiagnosticsModes
    case supportedDiagnosticsSnapshot
    case supportedFirmwareUpdateConfiguration
    case supportedMetrics
    case supportedTransferTransportConfiguration
    case tapType
    case targetVisibilityState
    case token
}

public extension UUID {
    
    init(characteristic: CharacteristicType) {
        self.init(bluetoothAccessory: (0x0002, characteristic.rawValue))
    }
}

public extension BluetoothUUID {
    
    init(characteristic: CharacteristicType) {
        self.init(uuid: .init(characteristic: characteristic))
    }
}

// MARK: - CustomStringConvertible

extension CharacteristicType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .accessoryType:
            return "Accessory Type"
        case .accessoryFlags:
            return "Accessory Flags"
        case .active:
            return "Active"
        case .activeIdentifier:
            return "Active Identifier"
        case .activityInterval:
            return "Activity Interval"
        case .administratorOnlyAccess:
            return "Administrator Only Access"
        case .applicationMatchingIdentifier:
            return "Application Matching Identifier"
        case .assetUpdateReadiness:
            return "Asset Update Readiness"
        case .audioFeedback:
            return "Audio Feedback"
        case .batteryLevel:
            return "Battery Level"
        case .batteryChargingCurrent:
            return "Battery Charging Current"
        case .batteryVoltage:
            return "Battery Voltage"
        case .batteryVoltageSteady:
            return "Battery Voltage Steady"
        case .batteryRatingVoltage:
            return "Battery Rating Voltage"
        case .batteryRechargeVoltage:
            return "Battery Recharge Voltage"
        case .batteryUnderVoltage:
            return "Battery Under Voltage"
        case .batteryBulkVoltage:
            return "Battery Bulk Voltage"
        case .batteryFloatVoltage:
            return "Battery Float Voltage"
        case .batteryType:
            return "Battery Type"
        case .brightness:
            return "Brightness"
        case .ccaEnergyDetectThreshold:
            return "CCA Energy Detect Threshold"
        case .ccaSignalDetectThreshold:
            return "CCA Signal Detect Threshold"
        case .carbonDioxideDetected:
            return "Carbon Dioxide Detected"
        case .carbonDioxideLevel:
            return "Carbon Dioxide Level"
        case .carbonDioxidePeakLevel:
            return "Carbon Dioxide Peak Level"
        case .carbonMonoxideDetected:
            return "Carbon Monoxide Detected"
        case .carbonMonoxideLevel:
            return "Carbon Monoxide Level"
        case .carbonMonoxidePeakLevel:
            return "Carbon Monoxide Peak Level"
        case .characteristicValueActiveTransitionCount:
            return "Characteristic Value Active Transition Count"
        case .characteristicValueTransitionControl:
            return "Characteristic Value Transition Control"
        case .chargingState:
            return "Charging State"
        case .closedCaptions:
            return "Closed Captions"
        case .colorTemperature:
            return "Color Temperature"
        case .configuredName:
            return "Configured Name"
        case .contactSensorState:
            return "Contact Sensor State"
        case .coolingThresholdTemperature:
            return "Cooling Threshold Temperature"
        case .cryptoHash:
            return "Crypto Hash"
        case .currentAirPurifierState:
            return "Current Air Purifier State"
        case .currentAirQuality:
            return "Current Air Quality"
        case .currentDoorState:
            return "Current Door State"
        case .currentFanState:
            return "Current Fan State"
        case .currentHeaterCoolerState:
            return "Current Heater Cooler State"
        case .currentHeatingCoolingState:
            return "Current Heating Cooling State"
        case .currentHorizontalTiltAngle:
            return "Current Horizontal Tilt Angle"
        case .currentHumidifierDehumidifierState:
            return "Current Humidifier Dehumidifier State"
        case .currentLightLevel:
            return "Current Light Level"
        case .currentMediaState:
            return "Current Media State"
        case .currentPosition:
            return "Current Position"
        case .currentRelativeHumidity:
            return "Current Relative Humidity"
        case .currentSlatState:
            return "Current Slat State"
        case .currentTemperature:
            return "Current Temperature"
        case .currentTiltAngle:
            return "Current Tilt Angle"
        case .currentTransport:
            return "Current Transport"
        case .currentVerticalTiltAngle:
            return "Current Vertical Tilt Angle"
        case .currentVisibilityState:
            return "Current Visibility State"
        case .currentWaterLevel:
            return "Current Water Level"
        case .displayOrder:
            return "Display Order"
        case .eventRetransmissionMaximum:
            return "Event Retransmission Maximum"
        case .eventTransmissionCounters:
            return "Event Transmission Counters"
        case .filterChangeIndication:
            return "Filter Change Indication"
        case .filterLifeLevel:
            return "Filter Life Level"
        case .filterResetChangeIndication:
            return "Filter Reset Change Indication"
        case .firmwareVersion:
            return "Firmware Version"
        case .firmwareUpdateReadiness:
            return "Firmware Update Readiness"
        case .firmwareUpdateStatus:
            return "Firmware Update Status"
        case .gridVoltage:
            return "Grid Voltage"
        case .gridFrequency:
            return "Grid Frequency"
        case .hardwareFinish:
            return "Hardware Finish"
        case .hardwareRevision:
            return "Hardware Revision"
        case .heartBeat:
            return "Heart Beat"
        case .heatingThresholdTemperature:
            return "Heating Threshold Temperature"
        case .holdPosition:
            return "Hold Position"
        case .hue:
            return "Hue"
        case .identifier:
            return "Identifier"
        case .identify:
            return "Identify"
        case .inUse:
            return "In Use"
        case .inputDeviceType:
            return "Input Device Type"
        case .inputSourceType:
            return "Input Source Type"
        case .inputVoltageRange:
            return "Input Voltage Range"
        case .inverterHeatSinkTemperature:
            return "Inverter Heat Sink Temperature"
        case .inverterBusVoltage:
            return "Inverter Bus Voltage"
        case .inverterChargerSourcePriority:
            return "Inverter Charger Source Priority"
        case .inverterMode:
            return "Inverter Mode"
        case .inverterOutputMode:
            return "Inverter Output Mode"
        case .inverterMaxParallel:
            return "Inverter Max Parallel"
        case .isConfigured:
            return "Is Configured"
        case .labelIndex:
            return "Label Index"
        case .labelNamespace:
            return "Label Namespace"
        case .leakDetected:
            return "Leak Detected"
        case .lockControlPoint:
            return "Lock Control Point"
        case .lockCurrentState:
            return "Lock Current State"
        case .lockLastKnownAction:
            return "Lock Last Known Action"
        case .lockManagementAutoSecurityTimeout:
            return "Lock Management Auto Security Timeout"
        case .lockPhysicalControls:
            return "Lock Physical Controls"
        case .lockTargetState:
            return "Lock Target State"
        case .lockEvents:
            return "Lock Events"
        case .logs:
            return "Logs"
        case .macRetransmissionMaximum:
            return "MAC Retransmission Maximum"
        case .macTransmissionCounters:
            return "MAC Transmission Counters"
        case .manufacturer:
            return "Manufacturer"
        case .maximumTransmitPower:
            return "Maximum Transmit Power"
        case .metricsBufferFullState:
            return "Metrics Buffer Full State"
        case .model:
            return "Model"
        case .motionDetected:
            return "Motion Detected"
        case .mute:
            return "Mute"
        case .name:
            return "Name"
        case .nitrogenDioxideDensity:
            return "Nitrogen Dioxide Density"
        case .obstructionDetected:
            return "Obstruction Detected"
        case .occupancyDetected:
            return "Occupancy Detected"
        case .operatingStateResponse:
            return "Operating State Response"
        case .outletInUse:
            return "Outlet In Use"
        case .outputVoltage:
            return "Output Voltage"
        case .outputFrequency:
            return "Output Frequency"
        case .outputApparentPower:
            return "Output Apparent Power"
        case .outputActivePower:
            return "Output Active Power"
        case .outputLoadPercent:
            return "Output Load Percent"
        case .outputSourcePriority:
            return "Output Source Priority"
        case .ozoneDensity:
            return "Ozone Density"
        case .pm10Density:
            return "PM10 Density"
        case .pm25Density:
            return "PM2.5 Density"
        case .pictureMode:
            return "Picture Mode"
        case .ping:
            return "Ping"
        case .positionState:
            return "Position State"
        case .powerModeSelection:
            return "Power Mode Selection"
        case .powerState:
            return "Power State"
        case .productData:
            return "Product Data"
        case .programMode:
            return "Program Mode"
        case .programmableSwitchEvent:
            return "Programmable Switch Event"
        case .programmableSwitchOutputState:
            return "Programmable Switch Output State"
        case .receivedSignalStrengthIndication:
            return "Received Signal Strength Indication"
        case .receiverSensitivity:
            return "Receiver Sensitivity"
        case .relativeHumidityDehumidifierThreshold:
            return "Relative Humidity Dehumidifier Threshold"
        case .relativeHumidityHumidifierThreshold:
            return "Relative Humidity Humidifier Threshold"
        case .remainingDuration:
            return "Remaining Duration"
        case .remoteKey:
            return "Remote Key"
        case .rotationDirection:
            return "Rotation Direction"
        case .rotationSpeed:
            return "Rotation Speed"
        case .saturation:
            return "Saturation"
        case .securitySystemAlarmType:
            return "Security System Alarm Type"
        case .securitySystemCurrentState:
            return "Security System Current State"
        case .securitySystemTargetState:
            return "Security System Target State"
        case .selectedDiagnosticsModes:
            return "Selected Diagnostics Modes"
        case .serialNumber:
            return "Serial Number"
        case .serialConsoleInput:
            return "Serial Input Console"
        case .serialConsoleOutput:
            return "Serial Output Console"
        case .setDuration:
            return "Set Duration"
        case .setupTransferTransport:
            return "Setup Transfer Transport"
        case .signalToNoiseRatio:
            return "Signal-to-Noise Ratio"
        case .slatType:
            return "Slat Type"
        case .sleepDiscoveryMode:
            return "Sleep Discovery Mode"
        case .sleepInterval:
            return "Sleep Interval"
        case .smokeDetected:
            return "Smoke Detected"
        case .softwareVersion:
            return "Software Version"
        case .solarInputCurrent:
            return "Solar Input Current"
        case .solarInputVoltage:
            return "Solar Input Voltage"
        case .stagedFirmwareVersion:
            return "Staged Firmware Version"
        case .statusActive:
            return "Status Active"
        case .statusFault:
            return "Status Fault"
        case .statusLowBattery:
            return "Status Low Battery"
        case .statusTampered:
            return "Status Tampered"
        case .sulphurDioxideDensity:
            return "Sulphur Dioxide Density"
        case .supportedAssetTypes:
            return "Supported Asset Types"
        case .supportedCharacteristicValueTransitionConfiguration:
            return "Supported Characteristic Value Transition Configuration"
        case .supportedDiagnosticsModes:
            return "Supported Diagnostics Modes"
        case .supportedDiagnosticsSnapshot:
            return "Supported Diagnostics Snapshot"
        case .supportedFirmwareUpdateConfiguration:
            return "Supported Firmware Update Configuration"
        case .supportedMetrics:
            return "Supported Metrics"
        case .supportedTransferTransportConfiguration:
            return "Supported Transfer Transport Configuration"
        case .swingMode:
            return "Swing Mode"
        case .tapType:
            return "Tap Type"
        case .targetAirPurifierState:
            return "Target Air Purifier State"
        case .targetDoorState:
            return "Target Door State"
        case .targetFanState:
            return "Target Fan State"
        case .targetHeaterCoolerState:
            return "Target Heater Cooler State"
        case .targetHeatingCoolingState:
            return "Target Heating Cooling State"
        case .targetHorizontalTiltAngle:
            return "Target Horizontal Tilt Angle"
        case .targetHumidifierDehumidifierState:
            return "Target Humidifier Dehumidifier State"
        case .targetMediaState:
            return "Target Media State"
        case .targetPosition:
            return "Target Position"
        case .targetRelativeHumidity:
            return "Target Relative Humidity"
        case .targetTemperature:
            return "Target Temperature"
        case .targetTiltAngle:
            return "Target Tilt Angle"
        case .targetVerticalTiltAngle:
            return "Target Vertical Tilt Angle"
        case .targetVisibilityState:
            return "Target Visibility State"
        case .temperatureDisplayUnits:
            return "Temperature Display Units"
        case .threadControlPoint:
            return "Thread Control Point"
        case .threadNodeCapabilities:
            return "Thread Node Capabilities"
        case .threadOpenthreadVersion:
            return "Thread OpenThread Version"
        case .threadStatus:
            return "Thread Status"
        case .token:
            return "Token"
        case .transmitPower:
            return "Transmit Power"
        case .valveType:
            return "Valve Type"
        case .volatileOrganicCompoundDensity:
            return "Volatile Organic Compound Density"
        case .volume:
            return "Volume"
        case .volumeControlType:
            return "Volume Control Type"
        case .volumeSelector:
            return "Volume Selector"
        case .wiFiCapabilities:
            return "WiFi Capabilities"
        case .wiFiConfiguration:
            return "WiFi Configuration"
        case .wiFiNetworkList:
            return "WiFi Network List"
        case .version:
            return "Version"
        case .setup:
            return "Setup"
        case .encryptedRead:
            return "Encrypted Read"
        case .statusJammed:
            return "Jammed Status"
        case .wiFiStatus:
            return "WiFi Status"
        case .loRaStatus:
            return "LoRa Status"
        }
    }
}
