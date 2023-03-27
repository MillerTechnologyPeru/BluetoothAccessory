//
//  AccessoryPeripheral.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT
import BluetoothAccessory

public struct AccessoryPeripheral <Peripheral: GATT.Peer>: Equatable, Hashable, Identifiable {
    
    public let peripheral: Peripheral
    
    /// UUID from iBeacon or Accessory Manufacturer Data
    public let id: UUID
    
    /// Name from scan response.
    public let name: String
    
    /// Advertised service from scan response.
    public let service: ServiceType
}

public struct AccessoryScanResponse: Equatable, Hashable {
    
    public let name: String
    
    public let service: ServiceType
}
