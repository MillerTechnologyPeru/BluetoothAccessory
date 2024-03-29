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
    
    func testAuthenticationService() async throws {
        
        let (peripheral, central, scanData) = try await testPeripheral()
        let server = try await TestServer(peripheral: peripheral)
        
        let owner = UUID()
        let key = Credential(id: UUID(), secret: KeyData())
        let setupSecret = server.setupSharedSecret
        let setupRequest = SetupRequest(
            id: key.id,
            secret: key.secret,
            user: owner
        )
        
        try await central.connection(for: scanData.peripheral) { connection in
            
            // id
            let id = try await connection.readIdentifier()
            XCTAssertEqual(id, server.id)
                        
            // configuration status
            var isConfigured = try await connection.readConfiguredState()
            XCTAssertFalse(isConfigured)
                        
            // write setup characteristic
            try await connection.setup(
                setupRequest,
                using: setupSecret
            )
            
            try await Task.sleep(nanoseconds: 10_000_000)
            
            isConfigured = try await connection.readConfiguredState()
            XCTAssert(isConfigured)
            
            try await Task.sleep(nanoseconds: 10_000_000)
            
            var serverKeys = await server.keys
            guard let ownerKey = serverKeys[key.id] else {
                XCTFail("Missing owner key")
                return
            }
            
            // verify new key
            XCTAssertEqual(ownerKey.id, key.id)
            XCTAssertEqual(ownerKey.permission, .owner)
            XCTAssertEqual(ownerKey.user, owner)
            
            // verify setup request reset
            let serverSetupValue = await server.authentication.setup
            XCTAssertNil(serverSetupValue) //authentication.setup = nil // reset value
            let serverSetupDatabaseValue = await peripheral[characteristic: server.authentication.$setup.handle]
            XCTAssertEqual(serverSetupDatabaseValue, Data())
            
            // identify
            try await connection.identify(key: key)
            try await Task.sleep(nanoseconds: 10_000_000)
            var lastIdentify = await server.lastIdentify
            XCTAssertNotNil(lastIdentify)
            
            // create new key
            try await Task.sleep(nanoseconds: 10_000_000)
            let newKey = NewKey(user: UUID())
            let invitation = try await connection.createKey(newKey, device: id, key: key)
            
            // confirm key
            try await Task.sleep(nanoseconds: 10_000_000)
            let (anytimeKey, anytimeKeyData) = try await connection.confirmKey(invitation)
            
            // identify with new key
            try await connection.identify(key: Credential(id: anytimeKey.id, secret: anytimeKeyData))
            try await Task.sleep(nanoseconds: 10_000_000)
            lastIdentify = await server.lastIdentify
            XCTAssertNotNil(lastIdentify)
            
            // validate keys
            try await Task.sleep(nanoseconds: 10_000_000)
            serverKeys = await server.keys
            XCTAssertEqual(Set([ownerKey.id, anytimeKey.id]), Set(serverKeys.map { $0.key }))
            
            // read and write power state
            var powerState = try await connection.readPowerState(
                service: BluetoothUUID(service: .outlet),
                key: key
            )
            var serverPowerState = await server.outlet.powerState
            XCTAssertEqual(serverPowerState, powerState)
            powerState.toggle()
            try await Task.sleep(nanoseconds: 10_000_000)
            try await connection.writePowerState(powerState, service: BluetoothUUID(service: .outlet), key: key)
            serverPowerState = await server.outlet.powerState
            XCTAssertEqual(serverPowerState, powerState)
            try await Task.sleep(nanoseconds: 10_000_000)
            powerState.toggle()
            try await connection.writePowerState(powerState, service: BluetoothUUID(service: .outlet), key: Credential(id: anytimeKey.id, secret: anytimeKeyData))
            serverPowerState = await server.outlet.powerState
            XCTAssertEqual(serverPowerState, powerState)
            
            // FIXME: Fix list reading
            // read keys
            //authentication.keys = [.key(ownerKey)]
            try await Task.sleep(nanoseconds: 10_000_000)
            Task {
                let keysList = try await connection.readKeys(key: key)
                    .reduce(into: [KeysCharacteristic.Item](), { $0.append($1.value) })
                XCTAssertEqual(Set(keysList.map { $0.id }), [ownerKey.id, anytimeKey.id])
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        withExtendedLifetime(server) { _ in }
        
        // cleanup
        await central.disconnectAll()
        await peripheral.stop()
    }
    
    func testBatteryService() async throws {
        
        let (peripheral, central, scanData) = try await testPeripheral()
        let server = try await TestServer(peripheral: peripheral)
        
        let user = UUID()
        let credential = Credential(id: user, secret: KeyData())
        let ownerKey = Key(
            id: credential.id,
            user: user,
            created: Date(),
            permission: .owner
        )
        await server.add(key: ownerKey, secret: credential.secret)
        
        try await central.connection(for: scanData.peripheral) { connection in
            
            // id
            let id = try await connection.readIdentifier()
            XCTAssertEqual(id, server.id)
            
            let isConfigured = try await connection.readConfiguredState()
            XCTAssert(isConfigured)
            
            // read battery service
            let statusLowBattery = try await connection.readStatusLowBattery(key: credential)
            let serverStatusLowBattery = await server.battery.statusLowBattery
            XCTAssertEqual(statusLowBattery, serverStatusLowBattery)
            
            let batteryLevel = try await connection.readBatteryLevel(key: credential)
            let serverBatteryLevel = await server.battery.batteryLevel
            XCTAssertEqual(batteryLevel, serverBatteryLevel)
            
            let chargingState = try await connection.readChargingState(key: credential)
            let serverChargingState = await server.battery.chargingState
            XCTAssertEqual(chargingState, serverChargingState)
        }
        
        withExtendedLifetime(server) { _ in }
        
        // cleanup
        await central.disconnectAll()
        await peripheral.stop()
    }
    
}

// MARK: - Extensions

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

// MARK: - Supporting Types

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
        
        let authentication = try await AuthenticationService(peripheral: peripheral)
        let outlet = try await OutletService(peripheral: peripheral)
        let battery = try await BatteryService(peripheral: peripheral)
        
        self.server = try await BluetoothAccessoryServer(
            peripheral: peripheral,
            delegate: self,
            id: id, 
            type: accessoryType,
            rssi: rssi,
            name: name,
            advertised: advertisedService,
            services: [
                information,
                authentication,
                outlet,
                battery
            ]
        )
    }
    
    nonisolated func log(_ message: String) {
        print("Accessory:", message)
    }
    
    nonisolated func didAdvertise(beacon: BluetoothAccessory.AccessoryBeacon) {
        
    }
    
    func key(for id: UUID) -> KeyData? {
        if id == Key.setup {
            return setupSharedSecret
        } else {
            return keySecrets[id]
        }
    }
    
    func add(key: Key, secret: KeyData) async {
        self.keys[key.id] = key
        self.keySecrets[key.id] = secret
        await self.server.update(AuthenticationService.self) {
            $0.isConfigured = true
        }
    }
    
    func willRead(_ handle: UInt16, authentication authenticationMessage: AuthenticationMessage?) async -> Bool {
        return true
    }
    
    
    func willWrite(_ handle: UInt16, authentication: BluetoothAccessory.AuthenticationMessage?) async -> Bool {
        return true
    }
    
    func didWrite(_ handle: UInt16, authentication authenticationMessage: AuthenticationMessage?) async {
        
        switch handle {
        case await information.$identify.handle:
            if await information.identify {
                guard let authenticationMessage = authenticationMessage,
                      let key = self.keys[authenticationMessage.id] else {
                    assertionFailure()
                    return
                }
                log("Did identify with key \(key.user)")
                lastIdentify = Date()
                // clear value
                await self.server.update(InformationService.self) {
                    $0.identify = false
                }
            }
        case await outlet.$powerState.handle:
            guard let authenticationMessage = authenticationMessage,
                  let key = self.keys[authenticationMessage.id] else {
                assertionFailure()
                return
            }
            let powerState = await self.outlet.powerState
            log("Did turn \(powerState ? "on" : "off") with key \(key.user)")
            
        case await authentication.$setup.handle:
            //assert(await authentication.$setup.value == characteristicValue)
            guard let request = await authentication.setup else {
                assertionFailure()
                return
            }
            // create new key
            let ownerKey = Key(setup: request)
            await self.add(key: ownerKey, secret: request.secret)
            log("Setup owner key for \(ownerKey.user)")
            // clear value
            await self.server.update(AuthenticationService.self) {
                $0.setup = nil
                $0.keys = [.key(ownerKey)]
            }
        
        case await authentication.$createKey.handle:
            guard let request = await authentication.createKey else {
                assertionFailure()
                return
            }
            // create a new key
            let newKey = NewKey(request: request)
            let secret = request.secret
            self.newKeys[newKey.id] = newKey
            self.keySecrets[newKey.id] = secret
            // update db
            await self.server.update(AuthenticationService.self) {
                $0.createKey = nil
                $0.keys.append(.newKey(newKey))
            }
        case await authentication.$confirmKey.handle:
            guard let request = await authentication.confirmKey,
                  let authenticationMessage = authenticationMessage,
                  let newKey = self.newKeys[authenticationMessage.id] else {
                assertionFailure()
                return
            }
            // confirm key
            let key = newKey.confirm()
            self.newKeys[authenticationMessage.id] = nil
            await add(key: key, secret: request.secret)
            // update db
            await self.server.update(AuthenticationService.self) {
                $0.createKey = nil
                $0.keys.removeAll(where: { $0.id == newKey.id })
                $0.keys.append(.key(key))
            }
        default:
            break
        }
    }
    
    func updateCryptoHash() async {
        await self.server.update(AuthenticationService.self) {
            $0.cryptoHash = Nonce()
        }
    }
}

extension TestServer {
    
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
    
    nonisolated var outlet: OutletService {
        get async {
            await server[OutletService.self]
        }
    }
    
    nonisolated var battery: BatteryService {
        get async {
            await server[BatteryService.self]
        }
    }
}
