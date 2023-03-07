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
    
    /// Writable descriptor for transmitting authorization.
    case authorization
    
    /// Writable request descriptor used for encryption. Optional. Write-only.
    case request
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
