//
//  AccessoryManagerSpotlight.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import BluetoothAccessory
import CoreSpotlight

#if canImport(CoreSpotlight) && os(iOS) || os(macOS)
internal extension AccessoryManager {
    
    func loadSpotlight() -> SpotlightController {
        let spotlight = SpotlightController(index: .default())
        spotlight.log = { [unowned self] in self.log("🔦 Spotlight: " + $0) }
        return spotlight
    }
    
    func updateSpotlight() async {
        guard SpotlightController.isSupported else { return }
        do { try await spotlight.reindexAll(Array(cache.values)) }
        catch { log("⚠️ Unable to update Spotlight: \(error.localizedDescription)") }
    }
}

// MARK: - CoreSpotlightSearchable

extension PairedAccessory: CoreSpotlightSearchable {
    
    public static var searchDomain: String { return "com.colemancda.BluetoothAccessory.Spotlight.Accessory" }
    
    public var searchIdentifier: String {
        return type(of: self).searchIdentifier(for: id)
    }
    
    public static func searchIdentifier(for accessory: UUID) -> String {
        AccessoryURL.accessory(accessory).rawValue
    }
    
    public func searchableAttributeSet() -> CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: Swift.type(of: self).itemContentType)
        attributeSet.displayName = name
        attributeSet.contentDescription = information.type.description
        attributeSet.version = information.softwareVersion.description
        //attributeSet.thumbnailData = Data()
        attributeSet.keywords = [
            information.id.uuidString,
            information.service.description,
            information.name,
            information.manufacturer,
            information.model,
            key.permission.type.localizedText
        ]
        return attributeSet
    }
}

#endif

