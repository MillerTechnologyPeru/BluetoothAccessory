//
//  AccessoryCharacteristicRow.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/27/23.
//

import Foundation
import SwiftUI
import Bluetooth
import BluetoothAccessory

public struct AccessoryCharacteristicRow: View {
        
    let characteristic: CharacteristicCache
    
    public var body: some View {
        StateView(characteristic: characteristic)
    }
}

internal extension AccessoryCharacteristicRow {
    
    struct StateView: View {
                
        let characteristic: CharacteristicCache
        
        var body: some View {
            content
        }
    }
}

internal extension AccessoryCharacteristicRow.StateView {
    
    var content: some View {
        switch BluetoothUUID.accessoryCharacteristicType[characteristic.metadata.type] {
        case .setup:
            #if os(iOS) && !APPCLIP
            return AnyView(AccessoryCharacteristicRow.Setup(accessory: characteristic.accessory))
            #else
            return AnyView(
                DetailRow(
                    title: Text(verbatim: characteristic.metadata.name),
                    detail: detailText
                )
            )
            #endif
        default:
            return AnyView(
                DetailRow(
                    title: Text(verbatim: characteristic.metadata.name),
                    detail: detailText
                )
            )
        }
    }
    
    var detailText: Text? {
        switch characteristic.value {
        case .none, .list:
            return nil
        case let .single(value):
            let description: String
            if let customDescription = customValueDescription(for: value) {
                description = customDescription
            } else if let unit = characteristic.metadata.unit {
                description = unit.description(for: value)
            } else {
                description = value.description
            }
            return Text(verbatim: description)
        }
    }
    
    func customValueDescription(for value: CharacteristicValue) -> String? {
        guard let characteristicType = BluetoothUUID.accessoryCharacteristicType[characteristic.metadata.type] else {
            return nil
        }
        switch characteristicType {
        case .accessoryType:
            guard let value = AccessoryType.init(characteristicValue: value) else {
                return nil
            }
            return value.description
        case .statusLowBattery:
            guard let value = StatusLowBattery.init(characteristicValue: value) else {
                return nil
            }
            return value.description
        case .chargingState:
            guard let value = ChargingState.init(characteristicValue: value) else {
                return nil
            }
            return value.description
        default:
            return nil
        }
    }
}
