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
import SFSafeSymbols
#if os(iOS)
import CodeScanner
#endif

public struct SetupAccessoryView: View {
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    public let accessory: UUID?
    
    private let success: ((UUID) -> ())?
    
    @State
    private var state: SetupState = .camera
    
    @State
    private var username = ""
    
    public init(
        accessory: UUID? = nil,
        success: ((UUID) -> ())? = nil
    ) {
        self.accessory = accessory
        self.success = success
        self.state = .camera
    }
    
    public init(
        accessory: UUID,
        sharedSecret: KeyData,
        success: ((UUID) -> ())? = nil
    ) {
        self.accessory = accessory
        self.success = success
        self.state = .confirm(accessory, sharedSecret)
    }
    
    public var body: some View {
        stateView
            .navigationTitle("Setup")
            .task {
                await loadUsername()
            }
    }
}

private extension SetupAccessoryView {
    
    #if os(iOS)
    func scanResult(_ result: Result<ScanResult, ScanError>) {
        let result = didScan(result)
        switch result {
        case let .success((accessory, secret)):
            self.state = .confirm(accessory, secret)
        case let .failure(error):
            self.state = .error(error)
        }
    }
    
    func didScan(_ result: Result<ScanResult, ScanError>) -> Result<(UUID, KeyData), Error> {
        switch result {
        case .success(let scanResult):
            return didScan(scanResult.string).mapError({ $0 as Error })
        case .failure(let error):
            return .failure(error)
        }
    }
    #endif
    
    func didScan(_ string: String) -> Result<(UUID, KeyData), BluetoothAccessoryError> {
        guard let accessoryURL = AccessoryURL(rawValue: string),
              case let .setup(accessory, secret) = accessoryURL,
              self.accessory == accessory || self.accessory == nil else {
            return .failure(.invalidQRCode)
        }
        return .success((accessory, secret))
    }
    
    func setup(accessory: UUID, using sharedSecret: KeyData, name: String) {
        self.state = .loading(accessory, name)
        Task {
            do {
                guard store.state == .poweredOn else {
                    throw BluetoothAccessoryError.bluetoothUnavailable
                }
                let peripheral = try await store.peripheral(for: accessory)
                try await store.setup(
                    peripheral,
                    using: sharedSecret,
                    name: name
                )
                self.state = .success(accessory, name)
            } catch {
                self.state = .error(error)
            }
        }
    }
    
    func loadUsername() async {
        do {
            if username.isEmpty {
                if let username = try await store.loadUsername() {
                    self.username = username
                }
            }
        }
        catch {
            store.log("Unable to load username. \(error)")
        }
    }
    
    func retry() {
        self.state = .camera
    }
    
    var stateView: some View {
        switch state {
        case .camera:
            #if os(iOS) && !targetEnvironment(simulator)
            return AnyView(CameraView(completion: scanResult))
            #else
            return AnyView(Text("Setup this accessory on your iOS device."))
            #endif
        case let .confirm(accessory, sharedSecret):
            return AnyView(
                ConfirmView(accessory: accessory, username: $username) { name in
                    setup(accessory: accessory, using: sharedSecret, name: name)
                }
            )
        case let .loading(accessory, name):
            return AnyView(
                LoadingView(
                    accessory: accessory,
                    name: name
                )
            )
        case let .error(error):
            return AnyView(
                ErrorView(
                    error: error,
                    retry: retry
                )
            )
        case let .success(accessory, name):
            return AnyView(
                SuccessView(
                    accessory: accessory,
                    name: name,
                    completion: success
                )
            )
        }
    }
}

internal extension SetupAccessoryView {
    
    enum SetupState {
        
        case camera
        case confirm(UUID, KeyData)
        case loading(UUID, String)
        case success(UUID, String)
        case error(Error)
    }
}

internal extension SetupAccessoryView {
    
    #if os(iOS)
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
        
        let accessory: UUID
        
        let confirm: (String) -> ()
        
        @Binding
        private var username: String
        
        init(
            accessory: UUID,
            username: Binding<String>,
            confirm: @escaping (String) -> Void
        ) {
            self.accessory = accessory
            self.confirm = confirm
            self._username = username
        }
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                TextField("Username", text: $username)
                Button("Configure") {
                    confirm(username)
                }
            }
            .padding(30)
        }
    }
    
    struct LoadingView: View {
        
        let accessory: UUID
        
        let name: String
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Text("Configuring accessory...")
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
    
    struct SuccessView: View {
        
        let accessory: UUID
        
        let name: String
        
        let completion: ((UUID) -> ())?
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Image(systemSymbol: .checkmarkCircleFill)
                    .symbolRenderingMode(.palette)
                    .accentColor(.green)
                Text("Successfully setup \(name).")
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
        SetupAccessoryView()
    }
}
#endif

