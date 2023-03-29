//
//  FileManager.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation

internal extension FileManager {
    
    /// Returns the container directory associated with the specified security application group identifier.
    func containerURL(for appGroup: String) -> URL? {
        return containerURL(forSecurityApplicationGroupIdentifier: appGroup)
    }
    
    var cachesDirectory: URL? {
        return urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    var documentsURL: URL? {
        return urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
