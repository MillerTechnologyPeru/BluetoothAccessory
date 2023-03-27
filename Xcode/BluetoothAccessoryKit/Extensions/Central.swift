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
import BluetoothAccessory

#if targetEnvironment(simulator)
public typealias NativeCentral = MockCentral
public typealias NativePeripheral = MockCentral.Peripheral
#else
public typealias NativeCentral = DarwinCentral
public typealias NativePeripheral = DarwinCentral.Peripheral
#endif

public extension NativeCentral {
    
    /// Wait for CoreBluetooth to be ready.
    func wait(
        for state: DarwinBluetoothState,
        warning: Int = 3,
        timeout: Int = 10
    ) async throws {
        
        var powerOnWait = 0
        var currentState = await self.state
        while currentState != state {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            powerOnWait += 1
            // inform user after 3 seconds
            if powerOnWait == warning {
                NSLog("Waiting for CoreBluetooth to be ready, please turn on Bluetooth")
            }
            guard powerOnWait < timeout
                else { throw DarwinCentralError.invalidState(currentState) }
            currentState = await self.state // update value for next loop
        }
    }
}
