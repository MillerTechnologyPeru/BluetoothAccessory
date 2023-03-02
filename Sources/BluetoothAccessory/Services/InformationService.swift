//
//  InformationService.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

public struct InformationService {
    
    public static var type: ServiceType { .information }
    
    @IdentifierCharacteristic
    public var id: UUID
    
    @NameCharacteristic
    public var name: String
    
    public var accessoryType: AccessoryType
    
    @IdentifyCharacteristic
    public var identify: Bool
    
    @NameCharacteristic
    public var manufacturer: String
    
    @NameCharacteristic
    public var model: String
    
    @NameCharacteristic
    public var serialNumber: String
    
    public var configuredName: String?
    
    public var firmwareRevision: String?
    
    public var hardwareRevision: String?
    
    public var softwareRevision: String?
}
