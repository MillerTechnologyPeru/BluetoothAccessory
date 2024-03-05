//
//  AccessoryManagerSpotlight.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/4/24.
//

import Foundation
import CoreSpotlight
import SwiftUI
import BluetoothAccessory
#if canImport(SFSafeSymbols) && !APPCLIP
import SFSafeSymbols
#endif

#if canImport(CoreSpotlight) && os(iOS) || os(macOS)
internal extension AccessoryManager {
    
    func loadSpotlight() -> SpotlightController {
        let log = { [unowned self] in self.log("🔦 Spotlight: " + $0) }
        let spotlight = SpotlightController(index: .default(), log: log)
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
    
    public func searchableAttributeSet() async -> CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: Swift.type(of: self).itemContentType)
        attributeSet.displayName = name
        attributeSet.contentDescription = information.type.description
        attributeSet.version = information.softwareVersion.description
        attributeSet.keywords = [
            information.id.uuidString,
            information.service.description,
            information.name,
            information.manufacturer,
            information.model,
            key.permission.type.localizedText
        ]
        
        // add image
        #if os(iOS)
        if #available(iOS 16.0, *) {
            do {
                let imageData = try await renderSpotlightImage()
                attributeSet.thumbnailData = imageData
            }
            catch {
                assertionFailure("\(error)")
            }
        }
        #endif
        
        return attributeSet
    }
    
    #if os(iOS)
    @MainActor
    @available(iOS 16.0, *)
    private func renderSpotlightImage() throws -> Data {
        let symbol = information.type.symbol
        let view = Image(systemSymbol: symbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.accent)
            .frame(width: 250, height: 250)
        let renderer = ImageRenderer(content: view)
        guard let pngData = renderer.uiImage?.pngData() else {
            throw CocoaError(.featureUnsupported)
        }
        return pngData
    }
    #endif
}

#endif

