//
//  AccessoryManagerCloudKit.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import CloudKit

public extension AccessoryManager {
    
    
}

internal extension AccessoryManager {
    
    func loadCloudContainer(identifier: String?) -> CKContainer {
        let container = identifier.flatMap { CKContainer(identifier: $0) } ?? .default()
        return container
    }
    
    #if os(iOS)
    func loadCloudKeyValueObserver() {
        // observe changes
        keyValueStoreObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: self.keyValueStore,
            queue: nil,
            using: { [unowned self] in self.cloudKeyValueDidChange($0) }
        )
    }
    #endif
}

private extension AccessoryManager {
    
    func cloudKeyValueDidChange(_ notification: Notification) {
        
    }
}
