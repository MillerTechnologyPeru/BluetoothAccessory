//
//  TLVCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import TLVCoding

public protocol TLVCharacteristic: GATTProfileCharacteristic {
    
    /// TLV Encoder used to encode values.
    static var encoder: TLVEncoder { get }
    
    /// TLV Decoder used to decode values.
    static var decoder: TLVDecoder { get }
}

public extension TLVCharacteristic {
    
    static var encoder: TLVEncoder { return .millerBluetooth }
    
    static var decoder: TLVDecoder { return .millerBluetooth }
}

public extension TLVCharacteristic where Self: Codable {
    
    init?(data: Data) {
        
        guard let value = try? Self.decoder.decode(Self.self, from: data)
            else { return nil }
        self = value
    }
    
    var data: Data {
        return try! Self.encoder.encode(self)
    }
}

public protocol TLVEncryptedCharacteristic: TLVCharacteristic, TLVCodable {
    
    var encryptedData: EncryptedData { get }
    
    init(encryptedData: EncryptedData)
}

public extension TLVEncryptedCharacteristic {
    
    init(from decoder: Decoder) throws {
        let encryptedData = try EncryptedData(from: decoder)
        self.init(encryptedData: encryptedData)
    }
    
    func encode(to encoder: Encoder) throws {
        try self.encryptedData.encode(to: encoder)
    }
    
    init?(tlvData: Data) {
        guard let encryptedData = EncryptedData(tlvData: tlvData) else {
            return nil
        }
        self.init(encryptedData: encryptedData)
    }
    
    var tlvData: Data {
        encryptedData.tlvData
    }
}
