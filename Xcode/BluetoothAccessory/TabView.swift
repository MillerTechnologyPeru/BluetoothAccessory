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
    
    @State
    private var setupSheet = false
    
    var body: some View {
        TabView(selection: $selection) {
            
            // Devices
            NavigationView {
                AccessoriesView()
                    .toolbar {
                        Button(action: {
                            setupSheet = true
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
        .sheet(isPresented: $setupSheet, onDismiss: { self.url = nil }) {
            NavigationView {
                switch url {
                case .setup(let uuid, let keyData):
                    SetupAccessoryView(accessory: uuid, sharedSecret: keyData, success: didSetup)
                default:
                    SetupAccessoryView(success: didSetup)
                }
            }
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
        let resolvedURL: AccessoryURL
        if store[cache: accessory] != nil {
            // dont show setup or invitation if paired
            resolvedURL = .accessory(accessory)
        } else {
            resolvedURL = accessoryURL
        }
        // handle link
        let tab: TabItem
        switch resolvedURL {
        case .accessory:
            // show accessory detail
            tab = .devices
        case  .setup:
            tab = .devices
            self.setupSheet = true
        case .newKey:
            tab = .devices
        }
        self.selection = tab
        self.url = resolvedURL
    }
    
    func didSetup(accessory: PairedAccessory) {
        self.url = .accessory(accessory.id)
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
