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
    
    @EnvironmentObject
    var store: AccessoryManager
    
    let characteristic: AccessoryManager.Characteristic
    
    let cache: CharacteristicCache
    
    public var body: some View {
        StateView(characteristic: characteristic, cache: cache)
    }
}

internal extension AccessoryCharacteristicRow {
    
    struct StateView: View {
        
        let characteristic: AccessoryManager.Characteristic
        
        let cache: CharacteristicCache
        
        var body: some View {
            SubtitleRow(
                title: Text(verbatim: cache.metadata.name),
                subtitle: subtitle
            )
        }
    }
}

internal extension AccessoryCharacteristicRow.StateView {
    
    var subtitle: Text? {
        switch cache.value {
        case .none:
            return nil
        case let .single(value):
            return Text(verbatim: value.description)
        case let .list(items):
            return Text("\(items.count) \("\(cache.metadata.format)") values")
        }
    }
}
