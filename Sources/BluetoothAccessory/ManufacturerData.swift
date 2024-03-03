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
    
    public var type: AccessoryType
    
    public var state: GlobalStateNumber
    
    public init(
        id: UUID,
        type: AccessoryType = .other,
        state: GlobalStateNumber = .setup
    ) {
        self.id = id
        self.type = type
        self.state = state
    }
}

public extension AccessoryManufacturerData {
    
    var isConfigured: Bool {
        state != .setup
    }
}

public extension AccessoryManufacturerData {
    
    static var length: Int { 20 }
    
    init?(manufacturerData: GATT.ManufacturerSpecificData) {
        guard manufacturerData.companyIdentifier == AccessoryManufacturerData.companyIdentifier,
              manufacturerData.additionalData.count == Self.length,
              let littleEndianUUID = UInt128(data: Data(manufacturerData.additionalData.prefix(UInt128.length))),
              let accessoryType = AccessoryType(rawValue: UInt16(littleEndian: UInt16(bytes: (manufacturerData.additionalData[16], manufacturerData.additionalData[17]))))
            else { return nil }
        self.id = UUID(UInt128(littleEndian: littleEndianUUID))
        self.type = accessoryType
        self.state = GlobalStateNumber(rawValue: UInt16(littleEndian: UInt16(bytes: (manufacturerData.additionalData[18], manufacturerData.additionalData[19]))))
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
        data += value.type.rawValue.littleEndian
        data += value.state.rawValue.littleEndian
    }
    
    /// Length of value when encoded into data.
    var dataLength: Int {
        Self.length
    }
}
