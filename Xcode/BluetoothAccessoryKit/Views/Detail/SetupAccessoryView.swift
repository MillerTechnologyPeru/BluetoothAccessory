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

#if canImport(SFSafeSymbols)
import SFSafeSymbols
#endif

#if canImport(CodeScanner) && os(iOS) && !APPCLIP
import CodeScanner
#endif

public struct SetupAccessoryView: View {
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    private let success: ((PairedAccessory) -> ())?
    
    @State
    private var state: SetupState
    
    @State
    private var configuredName = ""
    
    #if os(iOS) && !APPCLIP
    public init(
        accessory: UUID? = nil,
        success: ((PairedAccessory) -> ())? = nil
    ) {
        self.success = success
        _state = .init(initialValue: .camera(accessory))
    }
    #endif
    
    public init(
        accessory: UUID,
        sharedSecret: KeyData,
        success: ((PairedAccessory) -> ())? = nil
    ) {
        self.success = success
        _state = .init(initialValue: .scanning(accessory, sharedSecret))
    }
    
    public var body: some View {
        stateView
            .navigationTitle("Setup")
    }
}

private extension SetupAccessoryView {
    
    #if os(iOS) && !APPCLIP
    func scanCodeResult(_ result: Result<ScanResult, ScanError>) {
        let result = didScanCode(result)
        switch result {
        case let .success((accessory, secret)):
            self.state = .scanning(accessory, secret)
        case let .failure(error):
            self.state = .error(error)
        }
    }
    
    func didScanCode(_ result: Result<ScanResult, ScanError>) -> Result<(UUID, KeyData), Error> {
        switch result {
        case .success(let scanResult):
            return didScanCode(scanResult.string).mapError({ $0 as Error })
        case .failure(let error):
            return .failure(error)
        }
    }
    #endif
    
    func didScanCode(_ string: String) -> Result<(UUID, KeyData), BluetoothAccessoryError> {
        // Validate URL
        guard let url = URL(string: string),
              let accessoryURL = AccessoryURL(web: url),
              case let .setup(accessory, secret) = accessoryURL else {
            return .failure(.invalidQRCode)
        }
        // Validate UUID if provided
        if case let .camera(uuid) = state, let uuid {
            guard uuid == accessory else {
                return .failure(.invalidQRCode)
            }
        }
        return .success((accessory, secret))
    }
    
    func scan(for accessory: UUID, using sharedSecret: KeyData) {
        if let pairedAccessory = store[cache: accessory] {
            self.state = .success(pairedAccessory)
            return
        }
        self.state = .scanning(accessory, sharedSecret)
        let store = self.store
        let sleepTask = Task {
            try await Task.sleep(timeInterval: 1.0)
        }
        Task {
            let newState: SetupState
            do {
                let (peripheral, information) = try await store.setupScan(for: accessory)
                newState = .confirm(peripheral, information, sharedSecret)
            } catch {
                newState = .error(error, retry: {
                    self.scan(for: accessory, using: sharedSecret)
                })
            }
            try await sleepTask.value
            self.state = newState
        }
    }
    
    func setup(
        accessory: AccessoryPeripheral<NativePeripheral>,
        using sharedSecret: KeyData,
        with name: String
    ) {
        self.state = .pairing(accessory, name)
        let store = self.store
        let sleepTask = Task {
            try await Task.sleep(timeInterval: 1.0)
        }
        Task {
            let newState: SetupState
            do {
                // start pairing
                let pairedAccessory = try await store.setup(
                    accessory,
                    using: sharedSecret,
                    name: name
                )
                newState = .success(pairedAccessory)
            } catch {
                newState = .error(error, retry: { self.retry() })
            }
            try await sleepTask.value
            self.state = newState
        }
    }
    
    func retry() {
        self.state = .camera(nil)
        self.configuredName = ""
    }
    
    var stateView: some View {
        switch state {
        case .camera:
            #if os(iOS) && !targetEnvironment(simulator) && !APPCLIP
            return AnyView(CameraView(completion: scanCodeResult))
            #else
            return AnyView(Text("Setup this accessory on your iOS device."))
            #endif
        case let .scanning(accessory, sharedSecret):
            return AnyView(
                ScanningView(accessory: accessory)
                    .task {
                        scan(for: accessory, using: sharedSecret)
                    }
            )
        case let .confirm(accessory, information, sharedSecret):
            return AnyView(
                ConfirmView(information: information) { name in
                    setup(
                        accessory: accessory,
                        using: sharedSecret,
                        with: name
                    )
                }
            )
        case let .pairing(accessory, name):
            return AnyView(
                PairingView(
                    accessory: accessory,
                    name: name
                )
            )
        case let .error(error, retry):
            return AnyView(
                ErrorView(
                    error: error,
                    retry: retry
                )
            )
        case let .success(accessory):
            return AnyView(
                SuccessView(
                    accessory: accessory,
                    completion: success
                )
            )
        }
    }
}

internal extension SetupAccessoryView {
    
    enum SetupState {
        
        case camera(UUID?)
        case scanning(UUID, KeyData)
        case confirm(AccessoryPeripheral<NativePeripheral>, AccessoryInformation, KeyData)
        case pairing(AccessoryPeripheral<NativePeripheral>, String)
        case success(PairedAccessory)
        case error(Error, retry: () -> ())
    }
}

internal extension SetupAccessoryView {
    
    #if os(iOS) && !APPCLIP
    struct CameraView: View {
        
        let completion: ((Result<ScanResult, ScanError>) -> ())
        
        var body: some View {
            AnyView(
                CodeScannerView(codeTypes: [.qr], completion: completion)
            )
        }
    }
    #endif
    
    struct ConfirmView: View {
        
        let information: AccessoryInformation
        
        let confirm: (String) -> ()
        
        @State
        private var name = ""
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    if #available(iOS 16, macOS 13, *) {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemSymbol: information.type.symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Text("Name:")
                        TextField("\(information.name)", text: $name)
                    }
                    
                    Label(title: {
                        Text(verbatim: information.manufacturer)
                    }, icon: {
                        Text("Manufacturer:")
                    })
                    
                    Label(title: {
                        Text(verbatim: information.serialNumber)
                    }, icon: {
                        Text("Serial Number:")
                    })
                    
                    Spacer()
                    
                    // Configure Button
                    HStack {
                        Spacer()
                        Button("Configure") {
                            let name = name.isEmpty ? information.name : name
                            confirm(name)
                            self.name = ""
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(30)
            }
        }
    }
    
    struct PairingView: View {
        
        let accessory: AccessoryPeripheral<NativePeripheral>
        
        let name: String
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Text("Pairing \(name)")
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
    
    struct ScanningView: View {
        
        let accessory: UUID
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Text("Scanning...")
                #if DEBUG
                Text(verbatim: accessory.description)
                #endif
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
    
    struct SuccessView: View {
        
        let accessory: PairedAccessory
                
        let completion: ((PairedAccessory) -> ())?
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Image(systemSymbol: .checkmarkCircleFill)
                    .symbolRenderingMode(.palette)
                    .accentColor(.green)
                Text("Successfully setup \(accessory.name).")
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if let completion = self.completion {
                        Button("Done") {
                            completion(accessory)
                        }
                    }
                }
            }
        }
    }
    
    struct ErrorView: View {
        
        let error: Error
        
        let retry: () -> ()
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Image(systemSymbol: .exclamationmarkOctagonFill)
                    .symbolRenderingMode(.multicolor)
                Text("Error")
                Text(verbatim: error.localizedDescription)
                Button(action: retry) {
                    Text("Retry")
                }
            }
        }
    }
}

#if DEBUG
struct SetupAccessoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        SetupAccessoryView.ConfirmView(
            information: AccessoryInformation(
                id: UUID(),
                name: "Smart Bulb",
                type: .lightbulb,
                service: .lightbulb,
                manufacturer: "Smart Home Inc.",
                serialNumber: UUID().uuidString,
                model: "Bulb101",
                softwareVersion: "1.0.5"
            ), confirm: { name in
                print("Will pair accessory \(name)")
            }
        )
    }
}
#endif
