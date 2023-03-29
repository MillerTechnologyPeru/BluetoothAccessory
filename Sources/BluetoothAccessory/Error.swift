//
//  Error.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth

/// Bluetooth Accessory Error
public enum BluetoothAccessoryError: Error {
    
    /// Bluetooth is not available on this device.
    case bluetoothUnavailable
    
    /// No service with UUID found.
    case serviceNotFound(BluetoothUUID)
    
    /// No characteristic with UUID found.
    case characteristicNotFound(BluetoothUUID)
    
    /// The characteristic's value could not be parsed. Invalid data.
    case invalidCharacteristicValue(BluetoothUUID)
    
    /// Not a compatible peripheral
    case incompatiblePeripheral
    
    /// Invalid data.
    case invalidData(Data?)
    
    /// Invalid authentication HMAC signature.
    case invalidAuthentication
    
    /// Could not decrypt value.
    case decryptionError(Error)
    
    /// Could not encrypt value.
    case encryptionError(Error)
    
    /// Metadata is required for the specied characteristic.
    case metadataRequired(BluetoothUUID)
    
    /// A key is needed to authenticate the request.
    case authenticationRequired(BluetoothUUID)
        
    /// The specified accessory is not in range.
    case notInRange(UUID)
    
    /// No key for the specified accessory.
    case noKey(UUID)
    
    /// Must be an administrator for the specified accessory.
    case notAdmin(UUID)
    
    /// Invalid QR code.
    case invalidQRCode
    
    /// Invalid new key file.
    case invalidNewKeyFile
    
    /// You already have a key for this accessory.
    case existingKey(UUID)
    
    /// New key expired.
    case newKeyExpired
}
