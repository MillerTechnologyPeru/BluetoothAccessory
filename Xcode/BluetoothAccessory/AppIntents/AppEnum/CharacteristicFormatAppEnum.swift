//
//  CharacteristicFormatAppEnum.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 9/27/23.
//

import Foundation
import AppIntents
import BluetoothAccessoryKit

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
enum CharacteristicFormatAppEnum: UInt8, AppEnum, CaseIterable {
    
    case tlv8
    case string
    case data
    case date
    case uuid
    case bool
    case int8
    case int16
    case int32
    case int64
    case uint8
    case uint16
    case uint32
    case uint64
    case float
    case double
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Characteristic Format"
    }
    
    static var caseDisplayRepresentations: [CharacteristicFormatAppEnum : DisplayRepresentation] {
        [
            .tlv8: "TLV8",
            .string: "String",
            .data: "Data",
            .date: "Date",
            .uuid: "UUID",
            .bool: "Boolean",
            .int8: "Int8",
            .int16: "Int16",
            .int32: "Int32",
            .int64: "Int64",
            .uint8: "UInt8",
            .uint16: "UInt16",
            .uint32: "UInt32",
            .uint64: "UInt64",
            .float: "Float",
            .double: "Double",
        ]
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicFormatAppEnum {
    
    init(_ value: CharacteristicFormat) {
        self.init(rawValue: value.rawValue)!
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension CharacteristicFormat {
    
    init(_ value: CharacteristicFormatAppEnum) {
        self.init(rawValue: value.rawValue)!
    }
}
