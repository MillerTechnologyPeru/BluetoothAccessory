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
        
        let string = "bluetooth-accessory:/setup/524792BF-E5B6-49C9-AEDF-C352A100FD4B/b8Y72Q8SN9Bh7PCH2fNCU_oKp4sWu-dhv9x0n2tPIHk"
        
        guard let accessoryURL = AccessoryURL(rawValue: string)
            else { XCTFail("Invalid URL"); return }
        
        XCTAssertEqual(accessoryURL.rawValue, string)
        XCTAssertEqual(accessoryURL.description, string)
        
        guard case let .setup(identifier, secret) = accessoryURL
            else { XCTFail("Invalid URL"); return }
        
        XCTAssertEqual(identifier.uuidString, "524792BF-E5B6-49C9-AEDF-C352A100FD4B")
        XCTAssertEqual(secret.data.base64URLEncodedString(), "b8Y72Q8SN9Bh7PCH2fNCU_oKp4sWu-dhv9x0n2tPIHk")
    }
}
