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
    
    @State
    var url: AccessoryURL?
    
    private var setupSheet = false
    
    var body: some View {
        TabView(selection: $selection) {
            
            // Devices
            NavigationView {
                AccessoriesView()
                    .toolbar {
                        Button(action: {
                            showSetup = true
                        }, label: {
                            Image(systemSymbol: .plus)
                        })
                    }
                if let accessory = url?.accessory, store[cache: accessory] != nil {
                    AccessoryDetailView(accessory: accessory)
                } else {
                    VStack {
                        Text("Select an accessory.")
                    }
                }
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
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
        .sheet(isPresented: showSetup, onDismiss: { self.url = nil }) {
            SetupAccessoryView()
        }
    }
}

private extension AccessoryTabView {
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL,
              let accessoryURL = AccessoryURL(web: url) else {
            return
        }
        let accessory = accessoryURL.accessory
        // check if accessory is already paired
        if store[cache: accessory] != nil {
            // dont show setup or invitation if paired
            self.url = .accessory(accessory)
        } else {
            self.url = accessoryURL
        }
        // handle link
        let tab: TabItem
        switch self.url {
        case let .accessory(accessory):
            // show accessory detail
            tab = .devices
        }
    }
    
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

// MARK: - Supporting Types

internal extension AccessoryTabView {
    
    enum TabItem {
        
        case devices
        case nearby
        case contacts
        case settings
    }
}

#if DEBUG
struct AccessoryTabView_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryTabView()
            .environmentObject(BluetoothAccessoryApp.accessoryManager)
            .environment(\.managedObjectContext, BluetoothAccessoryApp.accessoryManager.managedObjectContext)
    }
}
#endif
