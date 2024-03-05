//
//  CoreSpotlight.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 4/4/24.
//  Copyright © 2024 ColemanCDA. All rights reserved.
//

#if canImport(CoreSpotlight) && os(iOS) || os(macOS)
import Foundation
import CoreSpotlight

#if canImport(MobileCoreServices)
import MobileCoreServices
#endif

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Manage the Spotlight index.
public final class SpotlightController {
    
    // MARK: - Initialization
        
    public init(index: CSSearchableIndex = .default()) {
        self.index = index
    }
    
    // MARK: - Properties
    
    internal let index: CSSearchableIndex
    
    public var log: ((String) -> ())?
    
    /// Returns a Boolean value that indicates whether indexing is available on the current device.
    public static var isSupported: Bool {
        return CSSearchableIndex.isIndexingAvailable()
    }
    
    // MARK: - Methods
    
    public func reindexAll<T: CoreSpotlightSearchable>(
        _ items: [T]
    ) async throws {
        
        let searchableItems = items
            .map { $0.searchableItem() }
        
        try await index.deleteSearchableItems(withDomainIdentifiers: [T.searchDomain])
        log?("Deleted all old items")
        try await index.indexSearchableItems(Array(searchableItems))
        log?("Indexed \(searchableItems.count) items")
    }
}

// MARK: - Supporting Types

public protocol CoreSpotlightSearchable {
    
    static var itemContentType: String { get }
    
    static var searchDomain: String { get }
    
    var searchIdentifier: String { get }
    
    func searchableItem() -> CSSearchableItem
    
    func searchableAttributeSet() -> CSSearchableItemAttributeSet
}

public extension CoreSpotlightSearchable {
    
    static var itemContentType: String { return UTType.text.identifier }
    
    func searchableItem() -> CSSearchableItem {
        let attributeSet = searchableAttributeSet()
        return CSSearchableItem(
            uniqueIdentifier: searchIdentifier,
            domainIdentifier: type(of: self).searchDomain,
            attributeSet: attributeSet
        )
    }
}
#endif
