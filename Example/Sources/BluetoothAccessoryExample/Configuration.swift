//
//  Configuration.swift
//  
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

import Foundation
import Bluetooth
import BluetoothAccessory

/// Device configuration.
public struct AccessoryConfiguration: Equatable, Hashable, Codable, JSONFile {
    
    /// Accessory Identifier
    public let id: UUID
    
    /// The received signal strength indicator (RSSI) value (measured in decibels) for the device.
    public let rssi: Int8
    
    /// The model of the accessory
    public let model: String
    
    /// The secret payload used for setup pairing.
    public let setupSecret: BluetoothAccessory.KeyData
    
    public init(
        id: UUID = UUID(),
        rssi: Int8,
        model: String,
        setupSecret: KeyData = KeyData()
    ) {
        self.id = id
        self.rssi = rssi
        self.model = model
        self.setupSecret = setupSecret
    }
}
