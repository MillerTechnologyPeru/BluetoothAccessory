//
//  ServerTests.swift
//  
//
//  Created by Alsey Coleman Miller on 3/24/23.
//

import Foundation
import XCTest
import Bluetooth
import BluetoothGATT
import GATT
@testable import BluetoothAccessory

final class ServerTests: XCTestCase {
    
    func testInformationService() async throws {
        
        let advertisingReports = [
            Data([0x3E, 0x2A, 0x02, 0x01, 0x00, 0x00, 0x01, 0x1E, 0x62, 0x6D, 0xE3, 0x94, 0x1E, 0x02, 0x01, 0x06, 0x1A, 0xFF, 0x4C, 0x00, 0x02, 0x15, 0xFD, 0xA5, 0x06, 0x93, 0xA4, 0xE2, 0x4F, 0xB1, 0xAF, 0xCF, 0xC6, 0xEB, 0x07, 0x64, 0x78, 0x25, 0x27, 0x12, 0x0B, 0x86, 0xBE, 0xBF])
        ]
        guard let reportData = advertisingReports.first?.suffix(from: 3),
            let report = HCILEAdvertisingReport(data: Data(reportData)),
            let serverAddress = report.reports.first?.address else {
            XCTFail("No scanned devices")
            return
        }
        
        let id = UUID()
        let rssi: Int8 = 20
        let name = "Lightbulb"
        let advertisedService = ServiceType.lightbulb
        let peripheral = TestPeripheral(address: serverAddress)
        peripheral.log = { print("Peripheral:", $0) }
        XCTAssertEqual(peripheral.hostController.address, serverAddress)
        
        let information = try await InformationService(
            peripheral: peripheral,
            id: id,
            name: name,
            accessoryType: .lightbulb,
            manufacturer: "Apple Inc.",
            model: "iLight1,1",
            serialNumber: UUID().uuidString,
            softwareVersion: "1.0.0",
            metadata: []
        )
        
        let server = try await BluetoothAccesoryServer(
            peripheral: peripheral,
            id: id,
            rssi: rssi,
            name: name,
            advertised: advertisedService,
            services: [
                information
            ]
        )
        
        let central = TestCentral()
        central.log = { print("Central:", $0) }
        central.hostController.advertisingReports = advertisingReports
        
        let scanStream = try await central.scan(filterDuplicates: true)
        guard let scanData = try await scanStream.first() else {
            XCTFail()
            return
        }
        
        try await central.connection(for: scanData.peripheral) { connection in
            // id
            let identifierCharacteristic = try await central.read(
                IdentifierCharacteristic.self,
                characteristic: connection.cache.characteristic(.identifier, service: .information)
            )
            XCTAssertEqual(identifierCharacteristic.value, id)
            
            // name
            let nameCharacteristic = try await central.read(
                NameCharacteristic.self,
                characteristic: connection.cache.characteristic(.name, service: .information)
            )
            XCTAssertEqual(nameCharacteristic.value, name)
            
            // accessory type
            let accessoryTypeCharacteristic = try await central.read(
                AccessoryTypeCharacteristic.self,
                characteristic: connection.cache.characteristic(.accessoryType, service: .information)
            )
            XCTAssertEqual(accessoryTypeCharacteristic.value, .lightbulb)
        }
    }
}
