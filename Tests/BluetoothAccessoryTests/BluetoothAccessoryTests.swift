import Foundation
import XCTest
import Bluetooth
import GATT
@testable import BluetoothAccessory

final class BluetoothAccessoryTests: XCTestCase {
    
    func testUUID() {
        
        let baseUUID = "-0000-1000-BA00-CDA000000CDA"
        let uuids: [(UInt32, String)] = [
            (0x00000000, "00000000-0000-1000-BA00-CDA000000CDA"),
            (0x00000001, "00000001-0000-1000-BA00-CDA000000CDA"),
            (0x00000002, "00000002-0000-1000-BA00-CDA000000CDA"),
            (0xFFFFFFFF, "FFFFFFFF-0000-1000-BA00-CDA000000CDA")
        ]
        
        for (value, string) in uuids {
            XCTAssertEqual(BluetoothUUID(accessory: value).description, string)
            XCTAssertEqual(UUID(bluetoothAccessory: value).description, string)
            XCTAssert(UUID(bluetoothAccessory: value).description.hasSuffix(baseUUID))
            XCTAssert(UUID(bluetoothAccessory: value).description.hasPrefix(value.toHexadecimal()))
        }
    }
    
    func testAccessoryType() {
        
        for accessory in AccessoryType.allCases {
            XCTAssertFalse(accessory.description.isEmpty)
        }
    }
    
    func testServiceType() {
        
        let values: [(ServiceType, String)] = [
            (.information,      "00010000-0000-1000-BA00-CDA000000CDA"),
            (.authentication,   "00010001-0000-1000-BA00-CDA000000CDA"),
            (.bridge,           "00010002-0000-1000-BA00-CDA000000CDA"),
            (.serial,           "00010003-0000-1000-BA00-CDA000000CDA"),
            (.battery,          "00010064-0000-1000-BA00-CDA000000CDA"),
            (.inverter,         "00010065-0000-1000-BA00-CDA000000CDA"),
            (.solarPanel,       "00010066-0000-1000-BA00-CDA000000CDA"),
            (.lightbulb,        "000100C8-0000-1000-BA00-CDA000000CDA"),
        ]
        
        for (serviceType, uuidString) in values {
            XCTAssertEqual(BluetoothUUID(service: serviceType), BluetoothUUID(rawValue: uuidString))
            XCTAssertEqual(BluetoothUUID(service: serviceType).description, uuidString)
        }
                
        for serviceType in ServiceType.allCases {
            XCTAssertEqual(ServiceType(uuid: BluetoothUUID(service: serviceType)), serviceType)
        }
        
        XCTAssertNil(ServiceType(uuid: BluetoothUUID()))
    }
    
    func testCharacteristicType() {
        
        XCTAssertEqual(BluetoothUUID(characteristic: .identifier).description, "00020000-0000-1000-BA00-CDA000000CDA")
        XCTAssertEqual(BluetoothUUID(characteristic: .accessoryType).description, "00020001-0000-1000-BA00-CDA000000CDA")
        
        let values: [(CharacteristicType, String)] = [
            (.identifier,       "00020000-0000-1000-BA00-CDA000000CDA"),
            (.accessoryType,    "00020001-0000-1000-BA00-CDA000000CDA"),
        ]
        
        for (characteristicType, uuidString) in values {
            XCTAssertEqual(BluetoothUUID(characteristic: characteristicType), BluetoothUUID(rawValue: uuidString))
            XCTAssertEqual(BluetoothUUID(characteristic: characteristicType).description, uuidString)
        }
        
        XCTAssertNil(CharacteristicType(uuid: BluetoothUUID()))
        
        for characteristicType in CharacteristicType.allCases {
            XCTAssertEqual(CharacteristicType(uuid: BluetoothUUID(characteristic: characteristicType)), characteristicType)
            XCTAssertFalse(characteristicType.description.isEmpty)
        }
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
    
    func testBeacon() {
        
        let beacons: [AccessoryBeacon] = [
            AccessoryBeacon(id: UUID(), type: .other, state: .setup),
            AccessoryBeacon(id: UUID(), type: .doorLock, state: 0x01),
            AccessoryBeacon(id: UUID(), type: AccessoryType.allCases.randomElement()!, state: GlobalStateNumber(rawValue: (UInt16(0x01) ..< 0xFF).randomElement()!))
        ]
        
        for beacon in beacons {
            XCTAssertEqual(beacon.id, AppleBeacon(bluetoothAccessory: beacon, rssi: 0).uuid)
            XCTAssertEqual(beacon.type.rawValue, AppleBeacon(bluetoothAccessory: beacon, rssi: 0).major)
            XCTAssertEqual(beacon.state.rawValue, AppleBeacon(bluetoothAccessory: beacon, rssi: 0).minor)
            XCTAssertEqual(AccessoryBeacon(beacon: AppleBeacon(bluetoothAccessory: beacon, rssi: 0)), beacon)
        }
    }
    
    func testManufacturerData() {
        
        let manufacturerData = AccessoryManufacturerData(
            id: UUID(),
            accessoryType: AccessoryType.allCases.randomElement()!,
            state: GlobalStateNumber(rawValue: .random(in: .min ..< .max))
        )
        
        XCTAssertEqual(AccessoryManufacturerData(manufacturerData: GATT.ManufacturerSpecificData(bluetoothAccessory: manufacturerData)), manufacturerData)
        XCTAssertNil(AccessoryManufacturerData(manufacturerData: GATT.ManufacturerSpecificData(companyIdentifier: .millerTechnology)))
        XCTAssertNil(AccessoryManufacturerData(manufacturerData: GATT.ManufacturerSpecificData(companyIdentifier: .apple)))
    }
    
    func testDefinedCharacteristic() {
        
        for type in CharacteristicType.allCases {
            guard AccessoryCharacteristicCache.characteristicsByType[type] != nil else { continue }
            XCTAssertEqual(type.accessoryType.type, BluetoothUUID(characteristic: type))
        }
    }
    
    func testCharacteristicMetadata() {
        XCTAssertEqual(CharacteristicMetadata(type: .identifier), CharacteristicMetadata(from: IdentifierCharacteristic.self))
        XCTAssertEqual(CharacteristicMetadata(type: .accessoryType), CharacteristicMetadata(from: AccessoryTypeCharacteristic.self))
    }
}
