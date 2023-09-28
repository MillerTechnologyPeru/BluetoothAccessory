//
//  AppIntents.swift
//  BluetoothAccessoryApp
//
//  Created by Alsey Coleman Miller on 9/28/23.
//

import Foundation
import AppIntents
import CoreModel
import BluetoothAccessoryKit

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension FetchRequest.Predicate.Compound.Logical​Type {
    
    init(_ appIntents: EntityQueryComparatorMode) {
        switch appIntents {
        case .and:
            self = .and
        case .or:
            self = .or
        }
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension FetchRequest.Predicate.Compound {
    
    init(mode: EntityQueryComparatorMode, subpredicates predicates: [FetchRequest.Predicate]) {
        switch mode {
        case .and:
            self = .and(predicates)
        case .or:
            self = .or(predicates)
        }
    }
}
