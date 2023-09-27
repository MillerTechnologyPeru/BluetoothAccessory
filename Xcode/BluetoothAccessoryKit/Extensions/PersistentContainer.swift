//
//  PersistentContainer.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import CoreData

internal extension NSPersistentContainer {
    
    func commit(_ block: @escaping (NSManagedObjectContext) throws -> ()) async {
        await performBackgroundTask {
            do {
                try block($0)
                if $0.hasChanges {
                    try $0.save()
                }
            } catch {
                print("⚠️ Unable to commit changes: \(error.localizedDescription)")
                #if DEBUG
                print(error)
                #endif
                assertionFailure("Core Data error")
                return
            }
        }
    }
}
