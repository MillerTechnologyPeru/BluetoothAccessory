//
//  Permission.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import BluetoothAccessory

public extension Permission.Schedule.Interval {
    
    /// 9 AM to 5 PM
    static var `default`: Permission.Schedule.Interval {
        return Permission.Schedule.Interval(rawValue: 9 * 60 ... (12 + 5) * 60)!
    }
}

public extension PermissionType {
    
    var localizedText: String {
        switch self {
        case .owner:
            return NSLocalizedString("Owner", comment: "Permission.Owner")
        case .admin:
            return NSLocalizedString("Admin", comment: "Permission.Admin")
        case .anytime:
            return NSLocalizedString("Anytime", comment: "Permission.Anytime")
        case .scheduled:
            return NSLocalizedString("Scheduled", comment: "Permission.Scheduled")
        }
    }
}

public extension Permission {
    
    var localizedText: String {
        
        switch self {
        case .owner, .admin, .anytime:
            return type.localizedText
        case let .scheduled(schedule):
            return schedule.localizedText
        }
    }
}

public extension Permission.Schedule {
    
    var localizedText: String {
        // FIXME: Localized schedule
        return NSLocalizedString("Scheduled", value: "Scheduled", comment: "Permission.Scheduled")
    }
}

public extension Permission.Schedule.Weekdays {
    
    var localizedText: String {
        let every = NSLocalizedString("Every", comment: "Permission.Scheduled.Weekdays.Every")
        if self == .none {
            return NSLocalizedString("Never", comment: "Permission.Scheduled.Weekdays.Never")
        } else if self == .all {
            return String(format: "%@ %@", every, NSLocalizedString("Day", comment: "Permission.Scheduled.Weekdays.Day"))
        } else {
            return String(format: "%@ %@", every, self.days.map({ $0.localizedText }).joined(separator: ", "))
        }
    }
}

public extension Permission.Schedule.Weekdays.Day {
    
    var localizedText: String {
        
        switch self {
        case .sunday:
            return NSLocalizedString("Sunday", comment: "Permission.Scheduled.Weekdays.Day.Sunday")
        case .monday:
            return NSLocalizedString("Monday", comment: "Permission.Scheduled.Weekdays.Day.Monday")
        case .tuesday:
            return NSLocalizedString("Tuesday", comment: "Permission.Scheduled.Weekdays.Day.Tuesday")
        case .wednesday:
            return NSLocalizedString("Wednesday", comment: "Permission.Scheduled.Weekdays.Day.Wednesday")
        case .thursday:
            return NSLocalizedString("Thursday", comment: "Permission.Scheduled.Weekdays.Day.Thursday")
        case .friday:
            return NSLocalizedString("Friday", comment: "Permission.Scheduled.Weekdays.Day.Friday")
        case .saturday:
            return NSLocalizedString("Saturday", comment: "Permission.Scheduled.Weekdays.Day.Saturday")
        }
    }
}
