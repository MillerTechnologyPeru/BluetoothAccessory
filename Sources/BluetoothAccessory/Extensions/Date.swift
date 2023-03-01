//
//  Date.swift
//
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation

internal extension Date {
    
    var removingMiliseconds: Date {
        Date(timeIntervalSinceReferenceDate: Double(Int(self.timeIntervalSinceReferenceDate)))
    }
}
