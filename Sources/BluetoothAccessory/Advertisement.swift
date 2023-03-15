//
//  Advertisement.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

#if canImport(BluetoothHCI)
import Foundation
import Bluetooth
import BluetoothHCI
import BluetoothGAP

public extension LowEnergyAdvertisingData {
    
    init(
        beacon: AccessoryBeacon,
        rssi: Int8,
        flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
    ) {
        self.init(beacon: AppleBeacon(bluetoothAccessory: beacon, rssi: rssi), flags: flags)
    }
    
    init(
        service: ServiceType,
        name: String
    ) {
        let maxLength = LowEnergyAdvertisingData.capacity - 16
        var name = name
        if name.utf8.count > maxLength {
            name = String(name.prefix(maxLength))
        }
        let encoder = GAPDataEncoder()
        let localName = GAPCompleteLocalName(name: name)
        let serviceUUID: GAPIncompleteListOf128BitServiceClassUUIDs = [UUID(service: service)]
        self = try! encoder.encodeAdvertisingData(localName, serviceUUID)
    }
}

public extension BluetoothHostControllerInterface {
    
    /// LE Advertise with iBeacon for accessory.
    func setAdvertisingData(
        beacon accessoryBeacon: AccessoryBeacon,
        rssi: Int8,
        flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR],
        interval: AdvertisingInterval = .min
    ) async throws {
        let beacon = AppleBeacon(bluetoothAccessory: accessoryBeacon, rssi: rssi)
        try await iBeacon(beacon, flags: flags, interval: interval)
    }
    
    /// Set scan response with service UUID and name.
    func setScanResponse(
        service: ServiceType,
        name: String
    ) async throws {
        
        do { try await enableLowEnergyAdvertising(false) }
        catch HCIError.commandDisallowed { }
        
        try await setLowEnergyScanResponse(.init(service: service, name: name))
        
        do { try await enableLowEnergyAdvertising() }
        catch HCIError.commandDisallowed { }
    }
}

#endif
