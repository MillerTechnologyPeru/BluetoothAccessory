//
//  AccessoryManagerFileManager.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import BluetoothAccessory

public extension AccessoryManager {
    
    
}

internal extension AccessoryManager {
    
    func loadContainerURL() -> URL {
        #if os(tvOS)
        guard let containerURL = fileManager.cachesDirectory
            else { fatalError("Could not open Caches directory"); }
        #else
        guard let containerURL = fileManager.containerURL(for: configuration.keychain.group)
            else { fatalError("Could not open App Group directory"); }
        #endif
        return containerURL
    }
    
    func loadCache() throws -> AccessoryCache {
        let file: AccessoryCache
        if fileManager.fileExists(atPath: containerURL.path) {
            file = AccessoryCache(url: <#T##URL#>)
        } else {
            
        }
    }
}

internal enum AccessoryManagerFile {
    
    case cache = "data.json"
    
}
