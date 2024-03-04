//
//  TabView.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import SwiftUI
import SFSafeSymbols
import BluetoothAccessoryKit

struct AccessoryTabView: View {
    
    @EnvironmentObject
    var store: AccessoryManager
    
    @State
    var selection: TabItem?
    
    var body: some View {
        TabView(selection: $selection) {
            
            // Devices
            NavigationView {
                AccessoriesView()
            }
            .tabItem { Label("Devices", systemSymbol: devicesTabSymbol) }
            .tag(TabItem.devices)
            
            #if DEBUG
            // Nearby
            NavigationView {
                NearbyDevicesView()
            }
            .tabItem { Label("Nearby", systemSymbol: .antennaRadiowavesLeftAndRight) }
            .tag(TabItem.nearby)
            #endif
            
            // Contacts
            NavigationView {
                EmptyView()
            }
            .tabItem { Label("Users", systemSymbol: .personCircle) }
            .tag(TabItem.contacts)
            
            // Settings
            NavigationView {
                EmptyView()
            }
            .tabItem { Label("Settings", systemSymbol: settingsTabSymbol) }
            .tag(TabItem.settings)
        }
        .task {
            try? await store.wait(for: .poweredOn)
        }
    }
}

internal extension AccessoryTabView {
    
    enum TabItem {
        
        case devices
        case nearby
        case contacts
        case settings
    }
}

private extension AccessoryTabView {
    
    var devicesTabSymbol: SFSymbol {
        if #available(iOS 16, *) {
            return selection == .devices ? .sensor : .sensorFill
        } else {
            return selection == .devices ? .lightbulbFill : .lightbulb
        }
    }
    
    var settingsTabSymbol: SFSymbol {
        return selection == .settings ? .gearshape : .gearshapeFill
    }
}

#if DEBUG
struct AccessoryTabView_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryTabView()
    }
}
#endif
