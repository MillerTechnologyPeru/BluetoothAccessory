//
//  AccessoryInformation.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import BluetoothAccessory

/// Paired accessory information.
public struct AccessoryInformation: Equatable, Hashable, Codable, Identifiable {
    
    /// Accessory identifier
    public let id: UUID
    
    /// Key for the paired accessory
    public let key: Key
    
    /// Accessory advertised service
    public let service: ServiceType
    
    /// Accessory type
    public let accessory: AccessoryType
    
    /// Accessory name
    public var name: String
}
