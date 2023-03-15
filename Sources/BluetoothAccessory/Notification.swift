//
//  Notification.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import Bluetooth
import GATT

public protocol GATTEncryptedNotificationProtocol {
        
    var chunk: Chunk { get }
    
    init(chunk: Chunk)
    
    static func from(chunks: [Chunk]) throws -> EncryptedData
    
    static func from(chunks: [Chunk], using key: KeyData) throws -> Notification
    
    static func from(_ value: EncryptedData, maximumUpdateValueLength: Int) throws -> [Self]
    
    static func from(_ value: Notification, id: UUID, key: KeyData, maximumUpdateValueLength: Int) throws -> [Self]
}

public struct EncryptedNotification: Equatable, Hashable {
    
    public var isLast: Bool
    
    public var value: EncryptedData
    
    public init(isLast: Bool, value: EncryptedData) {
        self.isLast = isLast
        self.value = value
    }
}

public extension EncryptedNotification {
    
    init?(chunks: [Chunk]) {
        self.init(data: Data(chunks: chunks))
    }
    
    func chunks(maximumUpdateValueLength: Int) -> [Chunk] {
        Chunk.from(self.data, maximumUpdateValueLength: maximumUpdateValueLength)
    }
    
    init?(data: Data) {
        guard data.count >= 2,
            let isLast = Bool(byteValue: data[0]),
            let encryptedData = EncryptedData(data: data.advanced(by: 1))
            else { return nil }
        self.isLast = isLast
        self.value = encryptedData
    }
    
    var data: Data {
        return Data([isLast.byteValue]) + value.data
    }
}
