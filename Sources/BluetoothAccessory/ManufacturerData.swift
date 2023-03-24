//
//  ManufacturerData.swift
//  
//
//  Created by Alsey Coleman Miller on 3/24/23.
//

import Foundation
import Bluetooth
import GATT
import TLVCoding

public struct AccessoryManufacturerData: Equatable, Hashable, Codable {
    
    public static var companyIdentifier: CompanyIdentifier { .millerTechnology }
    
    public let id: UUID
    
    public var accessoryType: AccessoryType
    
    public var isConfigured: Bool
    
    public init(
        id: UUID,
        accessoryType: AccessoryType,
        isConfigured: Bool = true
    ) {
        self.id = id
        self.accessoryType = accessoryType
        self.isConfigured = isConfigured
    }
}

public extension AccessoryManufacturerData {
    
    init?(manufacturerData: GATT.ManufacturerSpecificData) {
        guard manufacturerData.companyIdentifier == AccessoryManufacturerData.companyIdentifier else {
            return nil
        }
        do {
            self = try TLVDecoder.bluetoothAccessory.decode(AccessoryManufacturerData.self, from: manufacturerData.additionalData)
        }
        catch {
            return nil
        }
    }
}

public extension GATT.ManufacturerSpecificData {
    
    init(bluetoothAccessory: AccessoryManufacturerData) {
        let additionalData = try! TLVEncoder.bluetoothAccessory.encode(bluetoothAccessory)
        self.init(
            companyIdentifier: AccessoryManufacturerData.companyIdentifier,
            additionalData: additionalData
        )
    }
}
