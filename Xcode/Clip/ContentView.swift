//
//  ContentView.swift
//  Clip
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import SwiftUI
import BluetoothAccessory

struct ContentView: View {
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @State
    var url: AccessoryURL?
    
    var body: some View {
        NavigationStack {
            VStack {
                if store.state != .poweredOn {
                    Image(systemSymbol: .exclamationmarkTriangleFill)
                    Text("Enable Bluetooth")
                } else {
                    switch url {
                    case .accessory(let accessory):
                        AccessoryDetailView(accessory: accessory)
                    case .setup(let accessory, let sharedSecret):
                        if store[cache: accessory] != nil {
                            AccessoryDetailView(accessory: accessory)
                        } else {
                            SetupAccessoryView(accessory: accessory, sharedSecret: sharedSecret) { _ in
                                self.url = .accessory(accessory)
                            }
                        }
                    case .newKey(let invitation):
                        Text("Accessory Invitation \(invitation.device)")
                    case nil:
                        AccessoriesView()
                    }
                }
            }
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
    }
}

private extension ContentView {
    
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
    }
    
    var urlBinding: Binding<String> {
        Binding(get: { 
            url?.rawValue ?? ""
        }, set: { newValue in
            url = URL(string: newValue)
                .flatMap { AccessoryURL(web: $0) }
        })
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AccessoryAppClip.accessoryManager)
        .environment(\.managedObjectContext, AccessoryAppClip.accessoryManager.managedObjectContext)
}
