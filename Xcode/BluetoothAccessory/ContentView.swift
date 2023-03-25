//
//  ContentView.swift
//  BluetoothAccessory
//
//  Created by Alsey Coleman Miller on 3/25/23.
//

import SwiftUI
import BluetoothAccessoryKit

struct ContentView: View {
    
    @State
    var central = DarwinCentral()
    
    @State
    var peripherals = [DarwinCentral.Peripheral: String]()
    
    var body: some View {
        ForEach(items, id: \.description) {
            Text(verbatim: $0)
        }
        .task {
            do {
                let scanStream = try await central.scan()
                for try await scanData in scanStream {
                    let name = scanData.advertisementData.localName ?? scanData.peripheral.description
                    self.peripherals[scanData.peripheral] = name
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    private var items: [String] {
        return peripherals
            .lazy
            .sorted(by: { $0.key.description < $1.key.description })
            .map { $0.value }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
