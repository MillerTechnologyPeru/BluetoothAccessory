//
//  FormatDescriptor.swift
//  
//
//  Created by Alsey Coleman Miller on 3/2/23.
//

import Foundation
import Bluetooth
import GATT

/// Format Descriptor
public struct FormatDescriptor: Equatable, Hashable {
    
    public static var type: DescriptorType { .format }
    
    public init(value: CharacteristicFormat) {
        self.value = value
    }
    
    public var value: CharacteristicFormat
}

#if canImport(BluetoothGATT)
import BluetoothGATT

//extension FormatDescriptor: GATTDescriptor { }
#endif
