//
//  UUID.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

public extension UUID {
    
    init(bluetoothAccessory: UInt32) {
        self.init(UInt128(bluetoothAccessory: bluetoothAccessory))
    }
    
    init(bluetoothAccessory: (UInt16, UInt16)) {
        self.init(UInt128(bluetoothAccessory: bluetoothAccessory))
    }
}

public extension BluetoothUUID {
    
    init(accessory: UInt32) {
        let bytes = accessory.bigEndian.bytes
        self = .bit128(.init(bluetoothAccessory: accessory))
    }
    
    init(accessory: (UInt16, UInt16)) {
        self = .bit128(.init(bluetoothAccessory: accessory))
    }
}

internal extension UInt128 {
    
    init(bluetoothAccessory: UInt32) {
        let bytes = bluetoothAccessory.bigEndian.bytes
        self.init(bigEndian: .init(bytes: (bytes.0, bytes.1, bytes.2, bytes.3, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0x91, 0x00, 0x2C, 0xCC, 0xCC)))
    }
    
    init(bluetoothAccessory: (UInt16, UInt16)) {
        let bytes0 = bluetoothAccessory.0.bigEndian.bytes
        let bytes1 = bluetoothAccessory.1.bigEndian.bytes
        let value = UInt32(bigEndian: UInt32(bytes: (bytes0.0, bytes0.1, bytes1.0, bytes1.1)))
        self.init(bluetoothAccessory: value)
    }
}

internal extension UUID {
    
    static var zero: UUID { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! }
}
