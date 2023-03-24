//
//  ManufacturerData.swift
//  
//
//  Created by Alsey Coleman Miller on 3/24/23.
//

import Foundation
import Bluetooth
import GATT

public struct AccessoryManufacturerData: Equatable, Hashable, Codable {
    
    public static var companyIdentifier: CompanyIdentifier { .millerTechnology }
    
    public let id: UUID
    
    public var accessoryType: AccessoryType
    
    public var isConfigured: Bool
    
    public init(
        id: UUID,
        accessoryType: AccessoryType = .other,
        isConfigured: Bool = true
    ) {
        self.id = id
        self.accessoryType = accessoryType
        self.isConfigured = isConfigured
    }
}

public extension AccessoryManufacturerData {
    
    init?(manufacturerData: GATT.ManufacturerSpecificData) {
        guard manufacturerData.companyIdentifier == AccessoryManufacturerData.companyIdentifier,
              manufacturerData.additionalData.count == 19,
              let littleEndianUUID = UInt128(data: Data(manufacturerData.additionalData.prefix(UInt128.length))),
              let accessoryType = AccessoryType(rawValue: UInt16(littleEndian: UInt16(bytes: (manufacturerData.additionalData[16], manufacturerData.additionalData[17])))),
              let isConfigured = Bool(byteValue: manufacturerData.additionalData[18])
            else { return nil }
        self.id = UUID(UInt128(littleEndian: littleEndianUUID))
        self.accessoryType = accessoryType
        self.isConfigured = isConfigured
    }
}

public extension GATT.ManufacturerSpecificData {
    
    init(bluetoothAccessory: AccessoryManufacturerData) {
        self.init(
            companyIdentifier: AccessoryManufacturerData.companyIdentifier,
            additionalData: Data(bluetoothAccessory)
        )
    }
}

// MARK: - Data

extension AccessoryManufacturerData: DataConvertible {
    
    /// Append data representation into buffer.
    static func += <T: DataContainer> (data: inout T, value: AccessoryManufacturerData) {
        data += UInt128(uuid: value.id).littleEndian
        data += value.accessoryType.rawValue.littleEndian
        data += value.isConfigured.byteValue
    }
    
    /// Length of value when encoded into data.
    var dataLength: Int {
        19
    }
}
