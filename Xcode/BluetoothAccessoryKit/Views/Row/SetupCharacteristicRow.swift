//
//  CharacteristicRow.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import SwiftUI
import Bluetooth
import BluetoothAccessory

public extension AccessoryCharacteristicRow {
    
    struct Setup: View {
        
        let accessory: UUID
        
        @State
        var showingSheet = false
        
        public var body: some View {
            Button(action: {
                showingSheet.toggle()
            }, label: {
                SubtitleRow(title: Text("Pair Accessory"))
            })
            .sheet(isPresented: $showingSheet) {
                NavigationView {
                    SetupAccessoryView(accessory: accessory)
                }
            }
        }
    }
}
