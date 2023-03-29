//
//  SetupAccessoryView.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import SwiftUI
import Bluetooth
import BluetoothAccessory

public struct SetupAccessoryView: View {
    
    public let accessory: UUID
    
    @Environment(\.dismiss)
    var dismiss
    
    public var body: some View {
        Text("Setup \(accessory)")
            .toolbar {
                Button("Cancel") {
                    dismiss()
                }
            }
    }
}
