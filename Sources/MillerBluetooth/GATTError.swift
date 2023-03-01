//
//  Error.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// GATT Profile Error
public enum GATTProfileError: Error {
    
    /// No service with UUID found.
    case serviceNotFound(BluetoothUUID)
    
    /// No characteristic with UUID found.
    case characteristicNotFound(BluetoothUUID)
    
    /// The characteristic's value could not be parsed. Invalid data.
    case invalidCharacteristicValue(BluetoothUUID)
    
    /// Not a compatible peripheral
    case incompatiblePeripheral(Error?)
    
    /// Invalid data.
    case invalidData(Data?)
}

/*
// MARK: - CustomNSError

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

extension SmartLockGATTError: CustomNSError {
    
    public enum UserInfoKey: String {
        
        /// Bluetooth UUID value (for characteristic or service).
        case uuid = "com.colemancda.GATTProfileError.GATTProfileError.BluetoothUUID"
        
        /// Data
        case data = "com.colemancda.GATTProfileError.GATTProfileError.Data"
    }
    
    /// The domain of the error.
    public static var errorDomain: String { return "com.colemancda.GATTProfileError" }
    
    /// The error code within the given domain.
    //public var errorCode: Int
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        
        var userInfo = [String : Any](minimumCapacity: 2)
        
        switch self {
            
        case let .serviceNotFound(uuid):
            
            let description = String(format: NSLocalizedString("No service with UUID %@ found.", comment: "com.colemancda.GATTProfileError..GATTProfileError.serviceNotFound"), uuid.description)
            
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[UserInfoKey.uuid.rawValue] = uuid
            
        case let .characteristicNotFound(uuid):
            
            let description = String(format: NSLocalizedString("No characteristic with UUID %@ found.", comment: "com.colemancda.GATTProfileError..GATTProfileError.characteristicNotFound"), uuid.description)
            
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[UserInfoKey.uuid.rawValue] = uuid
            
        case let .invalidCharacteristicValue(uuid):
            
            let description = String(format: NSLocalizedString("The value of characteristic %@ could not be parsed.", comment: "com.colemancda.GATTProfileError..GATTProfileError.invalidCharacteristicValue"), uuid.description)
            
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[UserInfoKey.uuid.rawValue] = uuid
            
        case let .invalidData(data):
            
            let description = String(format: NSLocalizedString("Invalid data.", comment: "com.colemancda.GATTProfileError..GATTProfileError.invalidData"))
            
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[UserInfoKey.data.rawValue] = data
        }
        
        return userInfo
    }
}

#endif
*/
