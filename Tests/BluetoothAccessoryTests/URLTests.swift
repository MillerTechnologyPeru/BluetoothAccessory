//
//  URLTests.swift
//  
//
//  Created by Alsey Coleman Miller on 3/29/23.
//

import Foundation
import XCTest
@testable import BluetoothAccessory

final class URLTests: XCTestCase {
    
    func testSetup() {
        
        let string = "bluetooth-accessory:/setup/25261345-ADC6-4802-882B-613AD8E86BE1/AcDIoBrCWorulJh4WBRr2z0KTWxzXt9Rz37bOqHYChA="
        let url = URL(string: string)!
        
        guard let accessoryURL = AccessoryURL(rawValue: url)
            else { XCTFail("Invalid URL"); return }
        
        XCTAssertEqual(accessoryURL.rawValue, url)
        XCTAssertEqual(accessoryURL.description, string)
        
        guard case let .setup(identifier, secret) = accessoryURL
            else { XCTFail("Invalid URL"); return }
        
        XCTAssertEqual(identifier.uuidString, "25261345-ADC6-4802-882B-613AD8E86BE1")
        XCTAssertEqual(secret.data.base64EncodedString(), "AcDIoBrCWorulJh4WBRr2z0KTWxzXt9Rz37bOqHYChA=")
    }
}
