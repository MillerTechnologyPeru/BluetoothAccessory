//
//  AccessoryManagerContacts.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import Contacts
import CoreData
import CloudKit

public extension AccessoryManager {
    
    //#if !os(tvOS)
    @available(tvOS, unavailable)
    func updateContacts() async throws {
        
        // exclude self
        let contactStore = self.contactStore
        let currentUser = try await cloudContainer.userRecordID()
        
        // insert new contacts
        var insertedUsers = Set<String>()
        for try await user in cloudContainer.discoverAllUserIdentities() {
            guard let userRecordID = user.userRecordID,
                userRecordID != currentUser
                else { return }
            insertedUsers.insert(userRecordID.recordName)
            // save in CoreData
            await backgroundContext.commit {
                try $0.insert(contact: user, contactStore: contactStore)
            }
        }
        
        // delete old contacts
        let fetchRequest = NSFetchRequest<ContactManagedObject>()
        fetchRequest.entity = ContactManagedObject.entity()
        fetchRequest.sortDescriptors = [
            .init(keyPath: \ContactManagedObject.identifier, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "NONE %K IN %@", #keyPath(ContactManagedObject.identifier), insertedUsers)
        await backgroundContext.commit { (context) in
            try context.fetch(fetchRequest).forEach {
                context.delete($0)
            }
        }
    }
    //#endif
    
    func loadUsername() async throws -> String {
        return "" // TODO
    }
}

internal extension AccessoryManager {
    
    func loadContacts() -> CNContactStore {
        let contactStore = CNContactStore()
        return contactStore
    }
    
}
