//
//  CharacteristicType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

public enum CharacteristicType: UInt16, Codable, CaseIterable {
    
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
        self.init(uuidString: "650135C4-45D6-4A00-B240-DF6FE202" + characteristic.rawValue.toHexadecimal())!
    }
}

public extension BluetoothUUID {
    
    init(characteristic: CharacteristicType) {
        self.init(uuid: .init(characteristic: characteristic))
    }
}
