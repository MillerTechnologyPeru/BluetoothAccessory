//
//  AccessoryInformation.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import BluetoothAccessory

/// Paired accessory information.
public struct PairedAccessory: Equatable, Hashable, Codable, Identifiable, Sendable {
    
    /// Accessory identifier
    public var id: UUID {
        information.id
    }
    
    /// Accessory name
    public var information: AccessoryInformation
    
    /// Key for the paired accessory
    public let key: Key
    
    /// Configured customized name.
    public var name: String
}

public struct AccessoryInformation: Equatable, Hashable, Codable, Identifiable, Sendable {
    
    /// Accessory identifier
    public let id: UUID
    
    /// Accessory name
    public let name: String
    
    /// Accessory type
    public let accessory: AccessoryType
    
    /// Accessory advertised service
    public let service: ServiceType
    
    /// Manufacturer Name
    public let manufacturer: String
    
    public let serialNumber: String
    
    public let model: String
    
    public let softwareVersion: String
}
