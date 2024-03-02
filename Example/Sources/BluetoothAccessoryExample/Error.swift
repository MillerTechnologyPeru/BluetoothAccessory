//
//  Error.swift
//  
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

import Foundation

public enum CommandError: Error {
    
    /// Unable to load Bluetooth controller.
    case bluetoothUnavailable
}
