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
    
    case accessoryType
    case accessoryFlags
    case active
    case activeIdentifier
    case activityInterval
    case administratorOnlyAccess
    case applicationMatchingIdentifier
    case assetUpdateReadiness
    case audioFeedback
    case batteryLevel
    case batteryChargingCurrent
    case batteryVoltage
    case batteryVoltageSteady
    case batteryRatingVoltage
    case batteryRechargeVoltage
    case batteryUnderVoltage
    case batteryBulkVoltage
    case batteryFloatVoltage
    case batteryType
    case brightness
    case ccaEnergyDetectThreshold
    case ccaSignalDetectThreshold
    case carbonDioxideDetected
    case carbonDioxideLevel
    case carbonDioxidePeakLevel
    case carbonMonoxideDetected
    case carbonMonoxideLevel
    case carbonMonoxidePeakLevel
    case characteristicValueActiveTransitionCount
    case characteristicValueTransitionControl
    case chargingState
    case closedCaptions
    case colorTemperature
    case configuredName
    case contactSensorState
    case coolingThresholdTemperature
    case cryptoHash
    case currentAirPurifierState
    case currentAirQuality
    case currentDoorState
    case currentFanState
    case currentHeaterCoolerState
    case currentHeatingCoolingState
    case currentHorizontalTiltAngle
    case currentHumidifierDehumidifierState
    case currentLightLevel
    case currentMediaState
    case currentPosition
    case currentRelativeHumidity
    case currentSlatState
    case currentTemperature
    case currentTiltAngle
    case currentTransport
    case currentVerticalTiltAngle
    case currentVisibilityState
    case currentWaterLevel
    case displayOrder
    case eventRetransmissionMaximum
    case eventTransmissionCounters
    case filterChangeIndication
    case filterLifeLevel
    case filterResetChangeIndication
    case firmwareRevision
    case firmwareUpdateReadiness
    case firmwareUpdateStatus
    case gridVoltage
    case gridFrequency
    case hardwareFinish
    case hardwareRevision
    case heartBeat
    case heatingThresholdTemperature
    case holdPosition
    case hue
    case identifier
    case identify
    case inUse
    case inputDeviceType
    case inputSourceType
    case inputVoltageRange
    case inverterHeatSinkTemperature
    case inverterBusVoltage
    case inverterChargerSourcePriority
    case inverterMode
    case inverterOutputMode
    case inverterMaxParallel
    case isConfigured
    case labelIndex
    case labelNamespace
    case leakDetected
    case lockControlPoint
    case lockCurrentState
    case lockLastKnownAction
    case lockManagementAutoSecurityTimeout
    case lockPhysicalControls
    case lockTargetState
    case lockEvents
    case logs
    case macRetransmissionMaximum
    case macTransmissionCounters
    case manufacturer
    case maximumTransmitPower
    case metricsBufferFullState
    case model
    case motionDetected
    case mute
    case name
    case nitrogenDioxideDensity
    case obstructionDetected
    case occupancyDetected
    case operatingStateResponse
    case outletInUse
    case outputVoltage
    case outputFrequency
    case outputApparentPower
    case outputActivePower
    case outputLoadPercent
    case outputSourcePriority
    case ozoneDensity
    case pm10Density
    case pm25Density
    case pictureMode
    case ping
    case positionState
    case powerModeSelection
    case powerState
    case productData
    case programMode
    case programmableSwitchEvent
    case programmableSwitchOutputState
    case receivedSignalStrengthIndication
    case receiverSensitivity
    case relativeHumidityDehumidifierThreshold
    case relativeHumidityHumidifierThreshold
    case remainingDuration
    case remoteKey
    case rotationDirection
    case rotationSpeed
    case saturation
    case securitySystemAlarmType
    case securitySystemCurrentState
    case securitySystemTargetState
    case selectedDiagnosticsModes
    case serialNumber
    case serialConsole
    case setDuration
    case setupTransferTransport
    case signalToNoiseRatio
    case slatType
    case sleepDiscoveryMode
    case sleepInterval
    case smokeDetected
    case softwareRevision
    case solarInputCurrent
    case solarInputVoltage
    case stagedFirmwareVersion
    case statusActive
    case statusFault
    case statusLowBattery
    case statusTampered
    case sulphurDioxideDensity
    case supportedAssetTypes
    case supportedCharacteristicValueTransitionConfiguration
    case supportedDiagnosticsModes
    case supportedDiagnosticsSnapshot
    case supportedFirmwareUpdateConfiguration
    case supportedMetrics
    case supportedTransferTransportConfiguration
    case swingMode
    case tapType
    case targetAirPurifierState
    case targetDoorState
    case targetFanState
    case targetHeaterCoolerState
    case targetHeatingCoolingState
    case targetHorizontalTiltAngle
    case targetHumidifierDehumidifierState
    case targetMediaState
    case targetPosition
    case targetRelativeHumidity
    case targetTemperature
    case targetTiltAngle
    case targetVerticalTiltAngle
    case targetVisibilityState
    case temperatureDisplayUnits
    case threadControlPoint
    case threadNodeCapabilities
    case threadOpenthreadVersion
    case threadStatus
    case token
    case transmitPower
    case valveType
    case volatileOrganicCompoundDensity
    case volume
    case volumeControlType
    case volumeSelector
    case wiFiCapabilities
    case wiFiConfiguration
    case wiFiNetworkList
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
        case .firmwareRevision:
            return "Firmware Revision"
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
        case .serialConsole:
            return "Serial Console"
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
        case .softwareRevision:
            return "Software Revision"
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
        }
    }
}
