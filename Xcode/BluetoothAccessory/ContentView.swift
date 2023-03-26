//
//  ContentView.swift
//  BluetoothAccessory
//
//  Created by Alsey Coleman Miller on 3/25/23.
//

import SwiftUI
import BluetoothAccessoryKit

struct ContentView: View {
    
    @EnvironmentObject
    var store: AccessoryStore
    
    var body: some View {
        NavigationView {
            NearbyDevicesView()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
