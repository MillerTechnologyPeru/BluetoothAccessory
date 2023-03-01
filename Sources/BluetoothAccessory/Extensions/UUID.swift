//
//  UUID.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

public extension UUID {
    
    /// iBeacon Notification
    static var notificationBeacon: UUID {
        return UUID(uuidString: "F6AC86F3-A97D-4FA7-8668-C8ECFD1E538D")!
    }
}

internal extension UUID {
    
    static var zero: UUID { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! }
}
