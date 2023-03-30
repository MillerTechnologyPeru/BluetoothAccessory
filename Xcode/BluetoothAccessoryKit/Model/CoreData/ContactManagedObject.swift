//
//  ContactManagedObject.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 3/30/23.
//
import Foundation
import CoreData
import CloudKit
import Predicate

#if canImport(Contacts)
import Contacts
#endif

public final class ContactManagedObject: NSManagedObject {
    
    internal convenience init(
        identifier: String,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.identifier = identifier
    }
    
    internal static func find(_ identifier: String, in context: NSManagedObjectContext) throws -> ContactManagedObject? {
        try context.find(
            identifier: identifier as NSString,
            propertyName: #keyPath(ContactManagedObject.identifier),
            type: ContactManagedObject.self
        )
    }
}

// MARK: - Computed Properties

public extension ContactManagedObject {
    
    var nameComponents: PersonNameComponents? {
        get {
            var nameComponents = PersonNameComponents()
            nameComponents.namePrefix = namePrefix
            nameComponents.givenName = givenName
            nameComponents.middleName = middleName
            nameComponents.familyName = familyName
            nameComponents.nameSuffix = nameSuffix
            nameComponents.nickname = nickname
            return nameComponents
        }
        set {
            assert(newValue?.phoneticRepresentation == nil)
            namePrefix = newValue?.namePrefix
            givenName = newValue?.givenName
            middleName = newValue?.middleName
            familyName = newValue?.familyName
            nameSuffix = newValue?.nameSuffix
            nickname = newValue?.nickname
        }
    }
}

// MARK: - Fetch

public extension ContactManagedObject {
    
    static func fetch(in context: NSManagedObjectContext) throws -> [ContactManagedObject] {
        let fetchRequest = NSFetchRequest<ContactManagedObject>()
        fetchRequest.entity = entity()
        fetchRequest.fetchBatchSize = 40
        fetchRequest.sortDescriptors = [
            .init(keyPath: \ContactManagedObject.identifier, ascending: true)
        ]
        return try context.fetch(fetchRequest)
    }
}

internal extension NSManagedObjectContext {
    
    @discardableResult
    func insert(
        contact identity: CKUserIdentity,
        contactStore: CNContactStore
    ) throws -> ContactManagedObject? {
        
        guard let userRecordID = identity.userRecordID
            else { return nil }
        
        // find or create
        let identifier = userRecordID.recordName
        let managedObject = try ContactManagedObject.find(identifier, in: self)
            ?? ContactManagedObject(identifier: identifier, context: self)
        
        // update values
        managedObject.nameComponents = identity.nameComponents
        if let email = identity.lookupInfo?.emailAddress {
            managedObject.email = email
        }
        if let phoneNumber = identity.lookupInfo?.phoneNumber {
            managedObject.phone = phoneNumber
        }
        
        #if canImport(Contacts)
        // find contact in address book
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            do {
                let predicate = CNContact.predicateForContacts(withIdentifiers: identity.contactIdentifiers)
                let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [
                    CNContactThumbnailImageDataKey as NSString,
                    CNContactEmailAddressesKey as NSString,
                    CNContactPhoneNumbersKey as NSString
                ])
                managedObject.email = contacts.compactMap({ $0.emailAddresses.first?.value as String? }).first
                managedObject.phone = contacts.compactMap({ $0.phoneNumbers.first?.value.stringValue }).first
                managedObject.image = contacts.compactMap({ $0.thumbnailImageData }).first
            } catch {
                print("⚠️ Unable to update contact information from address book. \(error)")
            }
        }
        #endif
        
        return managedObject
    }
}
