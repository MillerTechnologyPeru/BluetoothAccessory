//
//  AccessoryManagerContacts.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import Contacts

public extension AccessoryManager {
    
    func loadUsername() async throws -> String {
        try await cloudContainer.userRecordID().recordName
    }
}
