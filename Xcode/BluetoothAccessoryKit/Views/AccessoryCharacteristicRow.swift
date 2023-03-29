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
            return AnyView(AccessoryCharacteristicRow.Setup(accessory: characteristic.accessory))
        default:
            return AnyView(
                SubtitleRow(
                    title: Text(verbatim: characteristic.metadata.name),
                    subtitle: subtitle
                )
            )
        }
    }
    
    var subtitle: Text? {
        switch characteristic.value {
        case .none:
            return nil
        case let .single(value):
            return Text(verbatim: customValueDescription(for: value) ?? value.description)
        case let .list(items):
            return Text("\(items.count) values")
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
        default:
            return nil
        }
    }
}
