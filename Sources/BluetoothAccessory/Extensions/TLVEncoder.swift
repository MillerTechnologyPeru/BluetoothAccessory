//
//  TLVEncoder.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import TLVCoding

// MARK: - Encoder

public extension TLVEncoder {
    
    static var bluetoothAccessory: TLVEncoder {
        var encoder = TLVEncoder()
        encoder.numericFormatting = .littleEndian
        encoder.uuidFormatting = .bytes
        encoder.dateFormatting = .secondsSince1970
        return encoder
    }
}

public extension TLVDecoder {
    
    static var bluetoothAccessory: TLVDecoder {
        var decoder = TLVDecoder()
        decoder.numericFormatting = .littleEndian
        decoder.uuidFormatting = .bytes
        decoder.dateFormatting = .secondsSince1970
        return decoder
    }
}

// MARK: - BluetoothUUID

extension BluetoothUUID: TLVCodable {
    
    public init?(tlvData: Data) {
        guard let littleEndian = BluetoothUUID(data: tlvData) else {
            return nil
        }
        self.init(littleEndian: littleEndian)
    }
    
    public var tlvData: Data {
        self.littleEndian.data
    }
}
