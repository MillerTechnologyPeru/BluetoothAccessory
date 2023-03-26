//
//  Central.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import CoreBluetooth
import Bluetooth
import GATT
import DarwinGATT

#if targetEnvironment(simulator)

public typealias NativeCentral = MockCentral
public typealias NativePeripheral = MockCentral.Peripheral

public extension NativeCentral {
    
    private struct Cache {
        static let central = MockCentral()
    }
    
    static var shared: NativeCentral {
        return Cache.central
    }
}

#else

public typealias NativeCentral = DarwinCentral
public typealias NativePeripheral = DarwinCentral.Peripheral

public extension NativeCentral {
    
    private struct Cache {
        static let central = DarwinCentral(
            options: .init(showPowerAlert: true)
        )
    }
    
    static var shared: NativeCentral {
        return Cache.central
    }
}

#endif
