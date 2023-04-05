//
//  AccessoryInformation.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import BluetoothAccessory

/// Paired accessory information.
public struct PairedAccessory: Equatable, Hashable, Codable, Identifiable {
    
    /// Accessory identifier
    public var id: UUID {
        information.id
    }
    
    /// Accessory name
    public var information: AccessoryInformation
    
    /// Key for the paired accessory
    public let key: Key
}

public struct AccessoryInformation: Equatable, Hashable, Codable, Identifiable {
    
    /// Accessory identifier
    public let id: UUID
    
    /// Accessory name
    public var name: String
    
    /// Accessory type
    public let accessory: AccessoryType
    
    /// Accessory advertised service
    public var service: ServiceType
    
    /// Manufacturer Name
    public var manufacturer: String
    
    public var serialNumber: String
    
    public var model: String
    
    public var softwareVersion: String
}
