//
//  UnitDescriptor.swift
//  
//
//  Created by Alsey Coleman Miller on 3/2/23.
//

import Foundation
import Bluetooth

public struct UnitDescriptor: Equatable, Hashable {
    
    public static var type: DescriptorType { .format }
    
    public init(value: CharacteristicFormat) {
        self.value = value
    }
    
    public var value: CharacteristicFormat
}
