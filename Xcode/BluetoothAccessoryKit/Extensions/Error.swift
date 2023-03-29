//
//  Error.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/28/23.
//

import Foundation
import BluetoothAccessory

// MARK: - CustomNSError

extension BluetoothAccessoryError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .notInRange(accessory):
            return "accessory \(accessory) Not in range" //R.string.error.notInRange()
        case let .noKey(accessory):
            return "No key for accessory \(accessory)" //R.string.error.noKey()
        case let .notAdmin(accessory):
            return "Not an admin of accessory \(accessory)" //R.string.error.notAdmin()
        case .invalidQRCode:
            return "Invalid QR code" //R.string.error.invalidQRCode()
        case .invalidNewKeyFile:
            return "Invalid key invitation" //R.string.error.invalidNewKeyFile()
        case let .existingKey(accessory):
            return "You already have an existing key for accessory \(accessory)" //R.string.error.existingKey()
        case .newKeyExpired:
            return "Key invitation expired" //R.string.error.newKeyExpired()
        case .bluetoothUnavailable:
            return "Bluetooth unavailable"
        case let .serviceNotFound(service):
            return "Service \(service) not found."
        case let .characteristicNotFound(characteristic):
            return "Characteristic \(characteristic) not found."
        case let .invalidCharacteristicValue(characteristic):
            return "Invalid value for characteristic \(characteristic)."
        case .incompatiblePeripheral:
            return "Bluetooth device is not a valid accessory."
        case .invalidData(_):
            return "Invalid data."
        case .invalidAuthentication:
            return "Invalid authentication."
        case let .decryptionError(error):
            return "Unable to decrypt. \(error.localizedDescription)"
        case let .encryptionError(error):
            return "Unable to encrypt. \(error.localizedDescription)"
        case let .metadataRequired(characteristic):
            return "Missing metadata for characteristic \(characteristic)."
        case let .authenticationRequired(characteristic):
            return "Authentication required for characteristic \(characteristic)."
        }
    }
}
