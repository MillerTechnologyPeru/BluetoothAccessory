//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 3/24/23.
//

import Foundation
import Bluetooth
import GATT

typealias TestPeripheral = GATTPeripheral<TestHostController, TestL2CAPSocket>

extension TestPeripheral {
    
    convenience init(
        address: BluetoothAddress = BluetoothAddress(rawValue: "00:1A:7D:DA:71:01")!,
        options: GATTPeripheralOptions = .init()
    ) {
        self.init(hostController: TestHostController(address: address), options: options, socket: TestL2CAPSocket.self)
    }
}

