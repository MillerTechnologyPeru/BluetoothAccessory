//
//  AccessoryCache.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import Bluetooth
import BluetoothAccessory

public struct AccessoryCache: Equatable, Hashable, Codable, JSONFile {
    
    /// Date application data was created.
    public let created: Date
    
    /// Date application data was last modified.
    public private(set) var updated: Date
    
    /// Persistent accessory information.
    public var accessories: [UUID: PairedAccessory] {
        didSet { if accessories != oldValue { didUpdate() } }
    }
    
    /// Update date when modified.
    private mutating func didUpdate() {
        updated = Date()
    }
    
    /// Initialize a new application data.
    public init() {
        self.created = Date()
        self.updated = Date()
        self.accessories = [:]
    }
}
