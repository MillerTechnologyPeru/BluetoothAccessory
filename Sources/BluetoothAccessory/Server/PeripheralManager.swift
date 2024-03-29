//
//  PeripheralManager.swift
//  
//
//  Created by Alsey Coleman Miller on 3/15/23.
//

#if canImport(BluetoothGATT)
import Foundation
import Bluetooth
import GATT

public protocol AccessoryPeripheralManager: PeripheralManager {
        
    func advertise(
        beacon: AccessoryBeacon,
        rssi: Int8,
        name: String,
        service: ServiceType
    ) async throws
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
        let flags: GAPFlags = [
            .lowEnergyGeneralDiscoverableMode,
            .notSupportedBREDR
        ]
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
#endif
