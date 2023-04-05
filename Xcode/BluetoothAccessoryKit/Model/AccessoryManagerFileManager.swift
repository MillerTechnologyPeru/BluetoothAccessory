//
//  AccessoryManagerFileManager.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import BluetoothAccessory

public extension AccessoryManager {
    
    func loadCache() throws -> AccessoryCache {
        let url = self.url(for: .cacheJSON)
        let file: AccessoryCache
        if fileManager.fileExists(atPath: url.path) {
            file = try AccessoryCache(url: url)
        } else {
            file = AccessoryCache()
            try file.write(to: url)
        }
        self.cache = file.accessories
        Task {
            await updateCoreDataCache()
        }
        return file
    }
    
    internal(set) subscript (cache id: UUID) -> PairedAccessory? {
        get {
            return self.cache[id]
        }
        set {
            do {
                var file = try loadCache()
                file.accessories[id] = newValue
                try file.write(to: url(for: .cacheJSON))
            }
            catch {
                assertionFailure("Unable to save cache. \(error)")
                return
            }
            self.cache[id] = newValue
            Task {
                await updateCoreDataCache()
            }
        }
    }
}

internal extension AccessoryManager {
    
    func loadContainerURL() -> URL {
        #if os(tvOS)
        guard let containerURL = fileManager.cachesDirectory
            else { fatalError("Could not open Caches directory"); }
        #else
        guard let containerURL = fileManager.containerURL(for: configuration.appGroup)
            else { fatalError("Could not open App Group directory"); }
        #endif
        return containerURL
    }
    
    func url(for file: AccessoryManagerFile) -> URL {
        return containerURL.appendingPathComponent(file.rawValue)
    }
}

internal enum AccessoryManagerFile: String {
    
    case cacheJSON      = "data.json"
    case cacheSqlite    = "data.sqlite"
}
