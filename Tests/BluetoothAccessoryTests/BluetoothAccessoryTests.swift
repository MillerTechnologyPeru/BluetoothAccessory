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
        XCTAssertEqual(BluetoothUUID(service: .authentication).description, "00010001-0000-1000-8000-0091002CCCCC")
    }
    
    func testCharacteristicType() {
        
        XCTAssertEqual(BluetoothUUID(characteristic: .identifier).description, "00020000-0000-1000-8000-0091002CCCCC")
        XCTAssertEqual(BluetoothUUID(characteristic: .accessoryType).description, "00020001-0000-1000-8000-0091002CCCCC")
    }
    
    func testCharacteristicValue() {
        
        let values: [CharacteristicValue] = [
            .tlv8(KeyData().data),
            .data(KeyData().data),
            .date(Date().removingMiliseconds),
            .uuid(UUID()),
            .string(UUID().uuidString),
            .double(.random(in: -1 ... 100)),
            .float(.random(in: -1 ... 100)),
            .uint8(.random(in: .min ..< .max)),
            .uint16(.random(in: .min ..< .max)),
            .uint32(.random(in: .min ..< .max)),
            .uint64(.random(in: .min ..< .max)),
            .int8(.random(in: .min ..< .max)),
            .int16(.random(in: .min ..< .max)),
            .int32(.random(in: .min ..< .max)),
            .int64(.random(in: .min ..< .max)),
        ]
        
        for value in values {
            XCTAssertEqual(value, CharacteristicValue(from: value.encode(), format: value.format))
        }
    }
}
