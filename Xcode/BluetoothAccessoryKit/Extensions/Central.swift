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

