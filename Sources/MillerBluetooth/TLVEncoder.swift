//
//  TLVEncoder.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import TLVCoding

public extension TLVEncoder {
    
    static var millerBluetooth: TLVEncoder {
        var encoder = TLVEncoder()
        encoder.numericFormatting = .littleEndian
        encoder.uuidFormatting = .bytes
        encoder.dateFormatting = .secondsSince1970
        return encoder
    }
}

public extension TLVDecoder {
    
    static var millerBluetooth: TLVDecoder {
        var decoder = TLVDecoder()
        decoder.numericFormatting = .littleEndian
        decoder.uuidFormatting = .bytes
        decoder.dateFormatting = .secondsSince1970
        return decoder
    }
}
