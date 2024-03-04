//
//  AccessoryAppEntity.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct AccessoryAppEntity: AppEntity {
    
    let id: UUID
    
    /// Accessory name
    @Property(title: "Name")
    var name: String
    
    /// Accessory type
    @Property(title: "Accessory Type")
    var type: AccessoryTypeAppEnum
    
    /// Accessory advertised service
    @Property(title: "Service")
    var service: ServiceTypeAppEnum
    
    /// Manufacturer Name
    @Property(title: "Manufacturer Name")
    var manufacturer: String
    
    @Property(title: "Serial Number")
    var serialNumber: String
    
    @Property(title: "Model")
    var model: String
    
    @Property(title: "Software Version")
    var softwareVersion: String
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryAppEntity {
    
    init(_ value: AccessoryInformation) {
        self.id = value.id
        self.name = value.name
        self.type = .init(value.type)
        self.service = .init(value.service)
        self.manufacturer = value.manufacturer
        self.serialNumber = value.serialNumber
        self.model = value.model
        self.softwareVersion = value.softwareVersion
    }
    
    init(_ value: AccessoryEntity) {
        self.id = value.id
        self.name = value.name
        self.type = .init(value.type)
        self.service = .init(value.service)
        self.manufacturer = value.manufacturer
        self.serialNumber = value.serialNumber
        self.model = value.model
        self.softwareVersion = value.softwareVersion
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryAppEntity {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Accessory",
        numericFormat: "\(placeholder: .int) accessories"
    )
    
    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(serialNumber)"
        )
    }
        
    static var defaultQuery = AccessoryEntityQuery()
}

// MARK: - Equatable

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension AccessoryAppEntity: Equatable {
    
    static func == (lhs: AccessoryAppEntity, rhs: AccessoryAppEntity) -> Bool {
        lhs.id == rhs.id
    }
}
