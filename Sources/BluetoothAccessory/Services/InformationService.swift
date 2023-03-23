//
//  InformationService.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

public struct InformationService: AccessoryService, Identifiable {
    
    public static var type: BluetoothUUID { BluetoothUUID(service: .information) }
    
    @ManagedCharacteristic<IdentifierCharacteristic>
    public var id: UUID
    
    @ManagedCharacteristic<NameCharacteristic>
    public var name: String
    
    @ManagedCharacteristic<AccessoryTypeCharacteristic>
    public var accessoryType: AccessoryType
    
    @ManagedCharacteristic<IdentifyCharacteristic>
    public var identify: Bool = false
    
    /*
    public var manufacturer: String
    
    public var model: String
    
    public var serialNumber: String
    
    public var configuredName: String?
    
    public var firmwareVersion: String?
    
    public var hardwareVersion: String?
    
    public var softwareVersion: String?
    */
}

public extension InformationService {
    
    static var characteristics: [any AccessoryCharacteristic.Type] {
        [
            IdentifierCharacteristic.self,
            NameCharacteristic.self,
            AccessoryTypeCharacteristic.self,
            IdentifyCharacteristic.self,
        ]
    }
    
    var characteristicValues: [ManagedCharacteristicValue] {
        [
            $id,
            $name,
            $accessoryType,
            $identify
        ]
    }
}
