//
//  Advertisement.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

#if os(macOS) || os(Linux)
import Foundation
import Bluetooth
import BluetoothHCI
import BluetoothGAP

public extension BluetoothHostControllerInterface {
    
    /// LE Advertise with iBeacon
    func setAdvertisingData(beacon uuid: UUID, rssi: Int8) async throws {
        
        do { try await enableLowEnergyAdvertising(false) }
        catch HCIError.commandDisallowed { }
        
        let beacon = AppleBeacon(uuid: uuid, rssi: rssi)
        let flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
        
        try await iBeacon(beacon, flags: flags, interval: .min)
        
        do { try await enableLowEnergyAdvertising() }
        catch HCIError.commandDisallowed { }
    }
    
    /// Set scan response with service UUID and name.
    func setScanResponse(service uuid: UUID, name: String) async throws {
        
        do { try await enableLowEnergyAdvertising(false) }
        catch HCIError.commandDisallowed { }
        
        let name = GAPCompleteLocalName(name: name)
        let serviceUUID: GAPIncompleteListOf128BitServiceClassUUIDs = [uuid]
        
        let encoder = GAPDataEncoder()
        let data = try encoder.encodeAdvertisingData(name, serviceUUID)
        
        try await setLowEnergyScanResponse(data)
        
        do { try await enableLowEnergyAdvertising() }
        catch HCIError.commandDisallowed { }
    }
}

#endif
