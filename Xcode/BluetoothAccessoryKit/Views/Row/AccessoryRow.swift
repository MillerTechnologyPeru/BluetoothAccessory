//
//  AccessoryRow.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import SwiftUI
import BluetoothAccessory

struct AccessoryRow: View {
    
    let accessory: PairedAccessory
    
    var body: some View {
        VStack(alignment: .leading) {
            if #available(iOS 16.0, *) {
                Label("\(accessory.name)", systemSymbol: accessory.information.type.symbol)
            } else {
                Text("\(accessory.name)")
            }
        }
    }
}
