//
//  NetworkMonitor.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Network

/// An observer that you use to monitor and react to network changes.
public final class NetworkMonitor: ObservableObject {
    
    public static let shared = NetworkMonitor()
    
    // MARK: - Properties
    
    private let pathMonitor: NWPathMonitor
    
    public var path: NWPath {
        return pathMonitor.currentPath
    }
    
    // MARK: - Initialization
    
    deinit {
        pathMonitor.cancel()
    }
    
    public init() {
        self.pathMonitor = NWPathMonitor()
        setupPathMonitor()
    }
    
    public init(interface: NWInterface.InterfaceType) {
        self.pathMonitor = NWPathMonitor(requiredInterfaceType: interface)
        setupPathMonitor()
    }
    
    // MARK: - Methods
    
    private func setupPathMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] _ in
            self?.objectWillChange.send()
        }
        pathMonitor.start(queue: .main)
    }
}
