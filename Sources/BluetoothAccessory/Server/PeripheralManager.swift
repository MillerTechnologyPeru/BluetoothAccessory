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
    
    func start(name: String, service: ServiceType, id: UUID, rssi: Int8) async throws
    
    func advertise(beacon: AccessoryBeacon, rssi: Int8) async throws
}

#if canImport(BluetoothHCI)
extension GATTPeripheral: AccessoryPeripheralManager {
    
    public func start(name: String, service: ServiceType, id: UUID, rssi: Int8) async throws {
        // write classic BT name
        try await hostController.writeLocalName(name)
        // advertise iBeacon and set interval
        try await hostController.setAdvertisingData(
            beacon: .id(id),
            rssi: rssi
        )
        let advertisingOptions = AdvertisingOptions(
            advertisingData: LowEnergyAdvertisingData(beacon: .id(id), rssi: rssi),
            scanResponse: LowEnergyAdvertisingData(service: service, name: name)
        )
        // publish GATT server, enable advertising
        try await start(options: advertisingOptions)
    }
    
    public func advertise(beacon: AccessoryBeacon, rssi: Int8) async throws {
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
    }
}
#endif


