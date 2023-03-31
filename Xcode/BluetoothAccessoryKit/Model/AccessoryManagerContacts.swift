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
    
    func loadUsername() async throws -> String? {
        guard try await cloudContainer.accountStatus() == .available else {
            return nil
        }
        if try await cloudContainer.applicationPermissionStatus(for: [.userDiscoverability]) != .granted {
            try await cloudContainer.requestApplicationPermission([.userDiscoverability])
        }
        let currentUser = try await cloudContainer.userRecordID()
        guard let userIdentity = try await cloudContainer.userIdentities(forUserRecordIDs: [currentUser])[currentUser] else {
            return nil
        }
        return try userIdentity.lookupInfo?.emailAddress ?? emailAddresses(for: userIdentity).first
    }
}

internal extension AccessoryManager {
    
    func loadContacts() -> CNContactStore {
        let contactStore = CNContactStore()
        return contactStore
    }
    
    func emailAddresses(for identity: CKUserIdentity) throws -> [String] {
        #if canImport(Contacts)
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return []
        }
        // find contact in address book
        let predicate = CNContact.predicateForContacts(withIdentifiers: identity.contactIdentifiers)
        let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [
            CNContactEmailAddressesKey as NSString
        ])
        return contacts.reduce(into: [], {
            $0 += $1.emailAddresses.map { $0.value as String }
        })
        #else
        return nil
        #endif
    }
}
