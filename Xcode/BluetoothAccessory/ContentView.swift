//
//  ContentView.swift
//  BluetoothAccessory
//
//  Created by Alsey Coleman Miller on 3/25/23.
//

import SwiftUI
import BluetoothAccessoryKit

struct ContentView: View {
    
    var body: some View {
        #if os(iOS)
        AccessoryTabView()
        #else
        AccessoryTabView()
        #endif
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
