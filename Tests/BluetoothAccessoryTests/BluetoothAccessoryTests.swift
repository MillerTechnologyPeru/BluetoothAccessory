import Foundation
import XCTest
import Bluetooth
@testable import BluetoothAccessory

final class BluetoothAccessoryTests: XCTestCase {
    
    func testUUID() {
        
        let baseUUID = "-0000-1000-8000-0091002CCCCC"
        let uuids: [(UInt32, String)] = [
            (0x00000000, "00000000-0000-1000-8000-0091002CCCCC"),
            (0x00000001, "00000001-0000-1000-8000-0091002CCCCC"),
            (0x00000002, "00000002-0000-1000-8000-0091002CCCCC"),
            (0xFFFFFFFF, "FFFFFFFF-0000-1000-8000-0091002CCCCC")
        ]
        
        for (value, string) in uuids {
            XCTAssertEqual(BluetoothUUID(accessory: value).description, string)
            XCTAssertEqual(UUID(bluetoothAccessory: value).description, string)
            XCTAssert(UUID(bluetoothAccessory: value).description.hasSuffix(baseUUID))
            XCTAssert(UUID(bluetoothAccessory: value).description.hasPrefix(value.toHexadecimal()))
        }
    }
    
    func testServiceType() {
        
        XCTAssertEqual(BluetoothUUID(service: .information).description, "00010000-0000-1000-8000-0091002CCCCC")
        XCTAssertEqual(BluetoothUUID(service: .bridge).description, "00010001-0000-1000-8000-0091002CCCCC")
    }
    
    func testCharacteristicType() {
        
        XCTAssertEqual(BluetoothUUID(characteristic: .accessoryType).description, "00020000-0000-1000-8000-0091002CCCCC")
        XCTAssertEqual(BluetoothUUID(characteristic: .accessoryFlags).description, "00020001-0000-1000-8000-0091002CCCCC")
    }
}
