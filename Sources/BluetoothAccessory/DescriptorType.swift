//
//  DescriptorType.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Descriptor Type
public enum DescriptorType: UInt16, Codable, CaseIterable {
    
    /// Data format of characteristic value. Required. Read-only.
    case format
    
    /// Unit type. Optional. Read-only.
    case unit
    
    /// Type of encryption used. Required. Read-only.
    case encryption
}

public extension UUID {
    
    init(descriptor: DescriptorType) {
        self.init(bluetoothAccessory: (0x0003, descriptor.rawValue))
    }
}

public extension BluetoothUUID {
    
    init(descriptor: DescriptorType) {
        self.init(uuid: .init(descriptor: descriptor))
    }
}

/// Accessory Descriptor
public enum AccessoryDescriptor: Equatable, Hashable, Codable {
    
    /// Data format of characteristic value. Required. Read-only.
    case format(CharacteristicFormat)
    
    /// Unit type. Optional. Read-only.
    case unit(CharacteristicUnit)
    
    /// Type of encryption used. Required. Read-only.
    case encryption(CharacteristicEncryption)
}

public extension AccessoryDescriptor {
    
    var type: DescriptorType {
        switch self {
        case .format:
            return .format
        case .unit:
            return .unit
        case .encryption:
            return .encryption
        }
    }
}
