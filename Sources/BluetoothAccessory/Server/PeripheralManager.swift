//
//  PeripheralManager.swift
//  
//
//  Created by Alsey Coleman Miller on 3/15/23.
//

import Foundation
import Bluetooth
import GATT

public protocol AccessoryPeripheralManager: PeripheralManager {
        
    func advertise(beacon: AccessoryBeacon, rssi: Int8, name: String, service: ServiceType) async throws
}

#if canImport(BluetoothHCI)
extension GATTPeripheral: AccessoryPeripheralManager {
    
    public func advertise(
        beacon: AccessoryBeacon,
        rssi: Int8,
        name: String,
        service: ServiceType
    ) async throws {
        // write classic BT name
        try await hostController.writeLocalName(name)
        // advertise iBeacon and set interval
        let flags: GAPFlags
        switch beacon {
        case .id:
            flags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
        case .characteristicChanged:
            flags = [.lowEnergyLimitedDiscoverableMode, .notSupportedBREDR]
        }
        try await hostController.setAdvertisingData(
            beacon: beacon,
            rssi: rssi,
            flags: flags
        )
        // set scan response with name and service UUID
        try await hostController.setScanResponse(service: service, name: name)
    }
}
#endif


