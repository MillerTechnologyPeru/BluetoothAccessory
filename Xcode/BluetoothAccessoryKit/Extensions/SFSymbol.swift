//
//  SFSymbol.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import BluetoothAccessory
import SFSafeSymbols

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension AccessoryType {
    
    var symbol: SFSymbol {
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
            return .switchProgrammable
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


#if DEBUG
import SwiftUI

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
