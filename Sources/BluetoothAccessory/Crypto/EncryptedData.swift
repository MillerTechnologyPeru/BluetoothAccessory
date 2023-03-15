//
//  EncryptedData.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import TLVCoding

public struct EncryptedData: Equatable, Hashable {
    
    /// HMAC signature, signed by secret.
    public let authentication: Authentication
    
    /// Encrypted data
    public let encryptedData: Data
}

public extension EncryptedData {
    
    init(encrypt data: Data, using key: KeyData, id: UUID) throws {
        let digest = Digest(hash: data)
        let message = AuthenticationMessage(digest: digest, id: id)
        let encryptedData = try encrypt(data, using: key, nonce: message.nonce, authentication: message)
        let authentication = Authentication(key: key, message: message)
        self.authentication = authentication
        self.encryptedData = encryptedData
    }
    
    func decrypt(using key: KeyData) throws -> Data {
        // validate HMAC
        guard authentication.isAuthenticated(using: key)
            else { throw BluetoothAccessoryError.invalidAuthentication }
        // attempt to decrypt
        return try BluetoothAccessory.decrypt(encryptedData, using: key, authentication: authentication.message)
    }
}

extension EncryptedData {
    
    internal static var authenticationPrefixLength: Int { 176 }
    
    public init?(data: Data) {
        let prefixLength = Self.authenticationPrefixLength
        guard data.count >= prefixLength else {
            return nil
        }
        let prefix = Data(data.prefix(prefixLength))
        guard let authentication = try? TLVDecoder.bluetoothAccessory.decode(Authentication.self, from: prefix) else {
            return nil
        }
        self.authentication = authentication
        self.encryptedData = data.count > prefixLength ? Data(data.suffix(from: prefixLength)) : Data()
    }
    
    public var data: Data {
        let authenticationData = try! TLVEncoder.bluetoothAccessory.encode(authentication)
        return authenticationData + encryptedData
    }
}
