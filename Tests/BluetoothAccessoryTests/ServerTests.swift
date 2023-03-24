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
        
        let (peripheral, central, scanData) = try await testPeripheral()
        let server = try await TestServer(peripheral: peripheral)
        
        try await central.connection(for: scanData.peripheral) { connection in
            
            // id
            let idCharacteristic = try await connection.readIdentifier()
            XCTAssertEqual(idCharacteristic, server.id)
            
            // name
            let nameCharacteristic = try await connection.readName()
            XCTAssertEqual(nameCharacteristic, server.name)
            
            // accessory type
            let accessoryTypeCharacteristic = try await connection.readAccessoryType()
            XCTAssertEqual(accessoryTypeCharacteristic, server.accessoryType)
            
        }
        
        withExtendedLifetime(server) { _ in }
        
        // cleanup
        await central.disconnectAll()
        await peripheral.stop()
    }
    
    func testSetup() async throws {
        
        let (peripheral, central, scanData) = try await testPeripheral()
        let server = try await TestServer(peripheral: peripheral)
        
        let ownerName = "colemancda@icloud.com"
        let key = Credential(id: UUID(), secret: KeyData())
        let setupSecret = server.setupSharedSecret
        let setupRequest = SetupRequest(
            id: key.id,
            secret: key.secret,
            name: ownerName
        )
        
        try await central.connection(for: scanData.peripheral) { connection in
            
            // id
            let id = try await connection.readIdentifier()
            XCTAssertEqual(id, server.id)
            
            // write setup characteristic
            try await connection.setup(
                setupRequest,
                using: setupSecret
            )
            
            var serverSetupValue = await server.authentication.setup
            XCTAssertEqual(serverSetupValue, setupRequest)
            
            try await Task.sleep(nanoseconds: 10_000_000)
            let serverKeys = await server.keys
            guard let ownerKey = serverKeys[key.id] else {
                XCTFail("Missing owner key")
                return
            }
            
            // verify new key
            XCTAssertEqual(ownerKey.id, key.id)
            XCTAssertEqual(ownerKey.permission, .owner)
            XCTAssertEqual(ownerKey.name, ownerName)
            
            // verify setup request reset
            try await Task.sleep(nanoseconds: 10_000_000)
            serverSetupValue = await server.authentication.setup
            XCTAssertNil(serverSetupValue, "Should reset setup request")
            let serverSetupDatabaseValue = await peripheral[characteristic: server.authentication.$setup.handle]
            XCTAssertEqual(serverSetupDatabaseValue, Data())
            
            // identify
            try await connection.identify(key: key)
            try await Task.sleep(nanoseconds: 10_000_000)
            let lastIdentify = await server.lastIdentify
            XCTAssertNotNil(lastIdentify)
            
            //authentication.setup = nil // reset value
            //authentication.keys = [.key(ownerKey)]
        }
        
        withExtendedLifetime(server) { _ in }
        
        // cleanup
        await central.disconnectAll()
        await peripheral.stop()
    }
}

extension ServerTests {
    
    func testPeripheral() async throws -> (TestPeripheral, TestCentral, ScanData<TestCentral.Peripheral, TestCentral.Advertisement>) {
        
        let advertisingReports = [
            Data([0x3E, 0x2A, 0x02, 0x01, 0x00, 0x00, 0x01, 0x1E, 0x62, 0x6D, 0xE3, 0x94, 0x1E, 0x02, 0x01, 0x06, 0x1A, 0xFF, 0x4C, 0x00, 0x02, 0x15, 0xFD, 0xA5, 0x06, 0x93, 0xA4, 0xE2, 0x4F, 0xB1, 0xAF, 0xCF, 0xC6, 0xEB, 0x07, 0x64, 0x78, 0x25, 0x27, 0x12, 0x0B, 0x86, 0xBE, 0xBF])
        ]
        guard let reportData = advertisingReports.first?.suffix(from: 3),
            let report = HCILEAdvertisingReport(data: Data(reportData)),
            let serverAddress = report.reports.first?.address else {
            fatalError("No scanned devices")
        }
        
        let peripheral = TestPeripheral(address: serverAddress)
        peripheral.log = { print("Peripheral:", $0) }
        XCTAssertEqual(peripheral.hostController.address, serverAddress)
        
        let central = TestCentral()
        central.log = { print("Central:", $0) }
        central.hostController.advertisingReports = advertisingReports
        
        let scanStream = try await central.scan(filterDuplicates: true)
        guard let scanData = try await scanStream.first() else {
            fatalError()
        }
        
        return (peripheral, central, scanData)
    }
}

actor TestServer <Peripheral: AccessoryPeripheralManager>: BluetoothAccessoryServerDelegate {
    
    let id = UUID()
    let rssi: Int8 = 20
    let accessoryType = AccessoryType.lightbulb
    let name = "Lightbulb"
    let manufacturer = "Apple Inc."
    let model = "iLight1,1"
    let serialNumber = UUID().uuidString
    let softwareVersion = "1.0.0"
    let advertisedService = ServiceType.lightbulb
    
    var keySecrets = [UUID: KeyData]()
    var keys = [UUID: Key]()
    var newKeys = [UUID: NewKey]()
    
    let setupSharedSecret = BluetoothAccessory.KeyData()
    
    var cryptoHash: Nonce {
        get async {
            await self.authentication.cryptoHash
        }
    }
    
    var lastIdentify: Date?
    
    private var server: BluetoothAccessoryServer<Peripheral>!
    
    nonisolated var information: InformationService {
        get async {
            await server[InformationService.self]
        }
    }
    
    nonisolated var authentication: AuthenticationService {
        get async {
            await server[AuthenticationService.self]
        }
    }
    
    init(peripheral: Peripheral) async throws {
        
        let information = try await InformationService(
            peripheral: peripheral,
            id: id,
            name: name,
            accessoryType: accessoryType,
            manufacturer: manufacturer,
            model: model,
            serialNumber: serialNumber,
            softwareVersion: softwareVersion,
            metadata: []
        )
        
        let authentication = try await AuthenticationService(
            peripheral: peripheral
        )
        
        self.server = try await BluetoothAccessoryServer(
            peripheral: peripheral,
            delegate: self,
            id: id,
            rssi: rssi,
            name: name,
            advertised: advertisedService,
            services: [
                information,
                authentication
            ]
        )
    }
    
    nonisolated func log(_ message: String) {
        print("Accessory:", message)
    }
    
    nonisolated func didAdvertise(beacon: BluetoothAccessory.AccessoryBeacon) {
        
    }
    
    func key(for id: UUID) -> KeyData? {
        self.keySecrets[id]
    }
    
    func didWrite(_ handle: UInt16) async {
        
        switch handle {
        case await authentication.$setup.handle:
            //assert(await authentication.$setup.value == characteristicValue)
            guard let request = await authentication.setup else {
                assertionFailure()
                return
            }
            // create new key
            let ownerKey = Key(setup: request)
            self.keys[ownerKey.id] = ownerKey
            self.keySecrets[ownerKey.id] = request.secret
            // clear value
            await self.server.update(AuthenticationService.self) {
                $0.setup = nil
            }
        case await information.$identify.handle:
            if await information.identify {
                log("Did identify")
                lastIdentify = Date()
                // clear value
                await self.server.update(InformationService.self) {
                    $0.identify = false
                }
            }
        default:
            return
        }
    }
    
    func updateCryptoHash() async {
        await self.server.update(AuthenticationService.self) {
            $0.cryptoHash = Nonce()
        }
    }
}
