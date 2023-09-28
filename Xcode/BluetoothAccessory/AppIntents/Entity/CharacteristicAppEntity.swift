//
//  CharacteristicAppEntity.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct CharacteristicAppEntity: AppEntity {
    
    let id: CharacteristicEntity.ID
    
    /// Characteristic name
    @Property(title: "Name")
    var name: String
    
    @Property(title: "Characteristic Type")
    var type: String
    
    @Property(title: "Service")
    var service: String
    
    @Property(title: "Accessory")
    var accessory: AccessoryAppEntity
    
    @Property(title: "Format")
    var format: CharacteristicFormatAppEnum
    
    @Property(title: "Unit")
    var unit: CharacteristicUnitAppEnum?
    
    @Property(title: "Encrypted")
    var isEncrypted: Bool
    
    @Property(title: "List")
    var isList: Bool
    
    @Property(title: "Readable")
    var isReadable: Bool
    
    @Property(title: "Writable")
    var isWritable: Bool
    
    @Property(title: "Write Without Response")
    var isWriteWithoutResponse: Bool
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicAppEntity {
    
    init(_ value: CharacteristicEntity, accessory: AccessoryAppEntity) {
        self.id = value.id
        self.accessory = accessory
        self.name = value.name
        self.type = value.type.rawValue
        self.service = value.service.rawValue
        self.format = .init(value.format)
        self.unit = value.unit.flatMap { .init($0) }
        self.isEncrypted = value.isEncrypted
        self.isList = value.isList
        self.isReadable = value.isReadable
        self.isWritable = value.isWritable
        self.isWriteWithoutResponse = value.isWriteWithoutResponse
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicAppEntity {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Characteristic",
        numericFormat: "\(placeholder: .int) characteristics"
    )
    
    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(BluetoothUUID(rawValue: service).flatMap({ ServiceType(uuid: $0) })?.description ?? service)"
        )
    }
    
    typealias DefaultQueryType = CharacteristicEntityQuery
    
    static var defaultQuery = CharacteristicEntityQuery()
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicEntity.ID: EntityIdentifierConvertible {
    
    public var entityIdentifierString: String {
        rawValue
    }

    /// Identifiers should be able to initialize via a `String` format.
    public static func entityIdentifier(for entityIdentifierString: String) -> CharacteristicEntity.ID? {
        .init(rawValue: entityIdentifierString)
    }
}
