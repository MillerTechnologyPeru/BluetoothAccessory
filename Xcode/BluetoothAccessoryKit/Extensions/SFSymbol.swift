//
//  SFSymbol.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import BluetoothAccessory
#if canImport(SFSafeSymbols) && !APPCLIP
import SFSafeSymbols
#endif

public extension AccessoryType {
    
    var symbol: SFSymbol {
        
        guard #available(iOS 16, *) else {
            switch self {
            case .bridge, .wiFiRouter, .rangeExtender:
                return .serverRack
            case .doorLock:
                return .lockFill
            case .lightbulb:
                return .lightbulbFill
            case .switch, .programmableSwitch:
                return .switch2
            case .thermostat:
                return .thermometer
            case .solarPanel:
                return .sunMaxFill
            case .inverter, .generator, .outlet:
                return .boltSquareFill
            case .securitySystem:
                return .lockShieldFill
            case .ipCamera:
                return .cameraFill
            case .speaker, .audioReceiver:
                return .hifispeakerFill
            case .television, .televisionSetTopBox:
                return .tvInsetFilled
            case .televisionStreamingStick:
                return .mediastick
            default:
                return .serverRack
            }
        }
        
        switch self {
        case .other:
            return .sensorFill
        case .bridge:
            return .serverRack
        case .fan:
            return .fanFloorFill
        case .garageDoorOpener:
            return .doorGarageClosed
        case .lightbulb:
            return .lightbulbLedFill
        case .doorLock:
            return .lockFill
        case .outlet:
            return .poweroutletTypeBFill
        case .inverter:
            return .boltBatteryblockFill
        case .generator:
            return .boltSquareFill
        case .solarPanel:
            return .sunMaxFill
        case .switch:
            return .lightswitchOn
        case .thermostat:
            return .thermometerHigh
        case .sensor:
            return .sensorFill
        case .securitySystem:
            return .lightBeaconMaxFill
        case .door:
            return .doorLeftHandClosed
        case .window:
            return .windowVerticalClosed
        case .windowCovering:
            return .windowShadeOpen
        case .programmableSwitch:
            return .switchProgrammable
        case .rangeExtender:
            return .wifiRouterFill
        case .ipCamera:
            return .webCameraFill
        case .videoDoorbell:
            return .videoDoorbellFill
        case .airPurifier:
            return .airPurifierFill
        case .airHeater:
            return .heaterVerticalFill
        case .airConditioner:
            return .airConditionerHorizontalFill
        case .airHumidifier:
            return .humidifierAndDropletsFill
        case .airDehumidifier:
            return .dehumidifierFill
        case .speaker:
            return .hifispeakerFill
        case .sprinkler:
            return .sprinklerAndDropletsFill
        case .faucet:
            return .spigotFill
        case .showerHead:
            return .showerFill
        case .television:
            return .tvInsetFilled
        case .targetController:
            return .wifiRouterFill
        case .wiFiRouter:
            return .wifiRouterFill
        case .audioReceiver:
            return .hifireceiverFill
        case .televisionSetTopBox:
            return .tvAndMediaboxFill
        case .televisionStreamingStick:
            return .mediastick
        }
    }
}

// MARK: - SFSymbols

import SwiftUI

#if APPCLIP
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public struct SFSymbol: RawRepresentable, Equatable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// 1.0 Symbols
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public extension SFSymbol {
    
    static let exclamationmarkOctagon = SFSymbol(rawValue: "exclamationmark.octagon")
    
    static let exclamationmarkOctagonFill = SFSymbol(rawValue: "exclamationmark.octagon.fill")
    
    static let checkmarkCircleFill = SFSymbol(rawValue: "checkmark.circle.fill")
    
    static let checkmarkCircle = SFSymbol(rawValue: "checkmark.circle")
    
    /// 􀇾
    static let exclamationmarkTriangle = SFSymbol(rawValue: "exclamationmark.triangle")
    
    /// 􀇿
    static let exclamationmarkTriangleFill = SFSymbol(rawValue: "exclamationmark.triangle.fill")
    
    static let lockFill = SFSymbol(rawValue: "lock.fill")
    
    /// 􀛭
    static let lightbulb = SFSymbol(rawValue: "lightbulb")

    /// 􀛮
    static let lightbulbFill = SFSymbol(rawValue: "lightbulb.fill")
    
    /// 􀇬
    static let thermometer = SFSymbol(rawValue: "thermometer")
    
    /// 􀆮
    static let sunMaxFill = SFSymbol(rawValue: "sun.max.fill")
    
    static let lockShieldFill = SFSymbol(rawValue: "lock.shield.fill")
    
    static let cameraFill = SFSymbol(rawValue: "camera.fill")
    
    static let hifispeakerFill = SFSymbol(rawValue: "hifispeaker.fill")
    
    
}

// 2.0 Symbols
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension SFSymbol {
    
    static let serverRack = SFSymbol(rawValue: "server.rack")
    
    static let switch2 = SFSymbol(rawValue: "switch.2")
}

// 3.0 Symbols
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension SFSymbol {
    
    static let boltSquareFill = SFSymbol(rawValue: "bolt.square.fill")
    
    static let tvInsetFilled = SFSymbol(rawValue: "tv.inset.filled")
    
    static let mediastick = SFSymbol(rawValue: "mediastick")

}

// 4.0 Symbols
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension SFSymbol {
    
    static let sensorFill = SFSymbol(rawValue: "sensor.fill")
    
    static let fanFloorFill = SFSymbol(rawValue: "fan.floor.fill")
    
    static let doorGarageClosed = SFSymbol(rawValue: "door.garage.closed")
    
    static let lightbulbLedFill = SFSymbol(rawValue: "lightbulb.led.fill")
    
    static let poweroutletTypeBFill = SFSymbol(rawValue: "poweroutlet.type.b.fill")

    static let boltBatteryblockFill = SFSymbol(rawValue: "bolt.batteryblock.fill")

    static let switchProgrammable = SFSymbol(rawValue: "switch.programmable")
    
    static let lightswitchOn = SFSymbol(rawValue: "lightswitch.on")
    
    static let lightswitchOnFill = SFSymbol(rawValue: "lightswitch.on.fill")

    static let thermometerHigh = SFSymbol(rawValue: "thermometer.high")

    static let lightBeaconMaxFill = SFSymbol(rawValue: "light.beacon.max.fill")

    static let doorLeftHandClosed = SFSymbol(rawValue: "door.left.hand.closed")

    static let windowVerticalClosed = SFSymbol(rawValue: "window.vertical.closed")

    static let windowShadeOpen = SFSymbol(rawValue: "window.shade.open")

    static let wifiRouterFill = SFSymbol(rawValue: "wifi.router.fill")

    static let webCameraFill = SFSymbol(rawValue: "web.camera.fill")

    static let videoDoorbellFill = SFSymbol(rawValue: "video.doorbell.fill")

    static let airPurifierFill = SFSymbol(rawValue: "air.purifier.fill")

    static let heaterVerticalFill = SFSymbol(rawValue: "heater.vertical.fill")

    static let airConditionerHorizontalFill = SFSymbol(rawValue: "air.conditioner.horizontal.fill")

    static let humidifierAndDropletsFill = SFSymbol(rawValue: "humidifier.and.droplets.fill")

    static let dehumidifierFill = SFSymbol(rawValue: "dehumidifier.fill")
    
    static let sprinklerAndDropletsFill = SFSymbol(rawValue: "sprinkler.and.droplets.fill")

    static let spigotFill = SFSymbol(rawValue: "spigot.fill")

    static let showerFill = SFSymbol(rawValue: "shower.fill")
    
    static let hifireceiverFill = SFSymbol(rawValue: "hifireceiver.fill")
    
    static let tvAndMediaboxFill = SFSymbol(rawValue: "tv.and.mediabox.fill")

    
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension Label where Title == Text, Icon == Image {
    
    /// Creates a label with a system symbol image and a title generated from a
    /// localized string.
    ///
    /// - Parameter systemSymbol: The `SFSymbol` describing this image. No image is shown if nil is passed.
    init(_ titleKey: LocalizedStringKey, systemSymbol: SFSymbol?) {
        self.init(titleKey, systemImage: systemSymbol?.rawValue ?? "")
    }
    
    /// Creates a label with a system symbol image and a title generated from a
    /// string.
    ///
    /// - Parameter systemSymbol: The `SFSymbol` describing this image. No image is shown if nil is passed.
    @_disfavoredOverload
    init<S>(_ title: S, systemSymbol: SFSymbol?) where S : StringProtocol {
        self.init(title, systemImage: systemSymbol?.rawValue ?? "")
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public extension SwiftUI.Image {
    
    /// Creates a system symbol image.
    ///
    /// - Parameter systemSymbol: The `SFSymbol` describing this image.
    init(systemSymbol: SFSymbol) {
        self.init(systemName: systemSymbol.rawValue)
    }

// AppIntents serves as a placeholder SDK to check if the iOS 16.0, macOS 13.0, ... SDKs are available
#if canImport(AppIntents)
    /// Creates a system symbol image with a variable value.
    ///
    /// - Parameter systemSymbol: The `SFSymbol` describing this image.
    /// - Parameter variableValue: An optional value between 0.0 and 1.0 that the rendered image can use to customize its appearance, if specified. If the symbol doesn’t support variable values, this parameter has no effect. Use the SF Symbols app to look up which symbols support variable values.
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    init(systemSymbol: SFSymbol, variableValue: Double?) {
        self.init(systemName: systemSymbol.rawValue, variableValue: variableValue)
    }
#endif
}

#endif

// MARK: - Previews

#if DEBUG

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct AccessorySymbol_Previews: PreviewProvider {
    
    struct SymbolListView: View {
        
        var body: some View {
            List {
                ForEach(AccessoryType.allCases, id: \.rawValue) { accessoryType in
                    VStack {
                        Label("\(accessoryType.description)", systemSymbol: accessoryType.symbol)
                    }
                }
            }
            .navigationTitle("Accessory Types")
        }
    }
    
    static var previews: some View {
        SymbolListView()
    }
}
#endif
