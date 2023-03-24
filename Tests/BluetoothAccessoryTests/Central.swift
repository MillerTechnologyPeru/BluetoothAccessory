//
//  TestCentral.swift
//  
//
//  Created by Alsey Coleman Miller on 3/24/23.
//

import Foundation
import Bluetooth
import GATT

typealias TestCentral = GATTCentral<TestHostController, TestL2CAPSocket>

extension TestCentral {
    
    convenience init(
        address: BluetoothAddress = BluetoothAddress(rawValue: "00:1A:7D:DA:71:02")!,
        options: GATTCentralOptions = .init()
    ) {
        self.init(hostController: TestHostController(address: address), options: options , socket: TestL2CAPSocket.self)
    }
}
