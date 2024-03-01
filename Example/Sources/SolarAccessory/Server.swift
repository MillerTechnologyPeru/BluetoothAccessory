//
//  Server.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

#if canImport(BluetoothGATT)
import Foundation
import Bluetooth
import BluetoothGATT
import GATT
import BluetoothAccessory
import BluetoothAccessoryExample

public actor SolarBluetoothServer <Peripheral: AccessoryPeripheralManager, Authentication: AuthenticationDelegate> {
    
    // MARK: - Properties
    
    public var id: UUID
    
    public var rssi: Int8
    
    public var model: String
    
    public var name: String
    
    public var manufacturer: String
    
    public var accessoryType: AccessoryType
    
    public var advertisedService: ServiceType
    
    public var softwareVersion: String
    
    public var serialNumber: String
    
    public var powerState = false
                
    private var server: BluetoothAccessoryServer<Peripheral>!
    
    public let refreshInterval: TimeInterval
    
    internal let authenticationDelegate: Authentication
    
    var lastIdentify: (UUID, Date)?
    
    public init(
        peripheral: Peripheral,
        id: UUID,
        rssi: Int8,
        model: String,
        serialNumber: String,
        softwareVersion: String,
        refreshInterval: TimeInterval,
        authentication authenticationDelegate: Authentication
    ) async throws {
        
        assert(refreshInterval >= 1)
        let name = "Solar"
        let manufacturer = "Miller Technology"
        let accessoryType = AccessoryType.solarPanel
        let advertisedService = ServiceType.solarPanel
        
        let information = try await InformationService(
            peripheral: peripheral,
            id: id,
            name: "MPPT Solar Inverter",
            accessoryType: accessoryType,
            manufacturer: manufacturer,
            model: model,
            serialNumber: serialNumber,
            softwareVersion: softwareVersion,
            metadata: []
        )
        
        // services
        let authentication = try await AuthenticationService(
            peripheral: peripheral,
            isConfigured: await authenticationDelegate.isConfigured,
            keys: await authenticationDelegate.allKeys
        )
        let battery = try await SolarBatteryService(peripheral: peripheral)
        let outlet = try await OutletService(peripheral: peripheral)
        
        // service delegate
        self.authenticationDelegate = authenticationDelegate
        
        // store properties
        self.id = id
        self.rssi = rssi
        self.model = model
        self.name = name
        self.manufacturer = manufacturer
        self.accessoryType = accessoryType
        self.advertisedService = advertisedService
        self.softwareVersion = softwareVersion
        self.serialNumber = serialNumber
        self.refreshInterval = refreshInterval
        
        // accessory server
        self.server = try await BluetoothAccessoryServer(
            peripheral: peripheral,
            delegate: self,
            id: id,
            rssi: rssi,
            name: name,
            advertised: advertisedService,
            services: [
                information,
                authentication,
                battery,
                outlet,
            ]
        )
        
        // add GATT device information
        #if os(Linux)
        try await addStandardDeviceInformation()
        #endif
        
        // read data from device
        try await refresh()
        
        // reload periodically
        Task { [weak self] in
            while let self = self {
                try await Task.sleep(timeInterval: self.refreshInterval)
                do {
                    try await self.refresh()
                }
                catch {
                    self.log("Unable to reload data: \(error)")
                }
            }
        }
    }
    
    private func addStandardDeviceInformation() async throws {
        
        let gattInformation = GATTAttribute.Service(
            uuid: .deviceInformation,
            characteristics: [
                GATTAttribute.Characteristic(
                    uuid: GATTManufacturerNameString.uuid,
                    value: GATTManufacturerNameString(rawValue: manufacturer).data,
                    permissions: [.read],
                    properties: [.read],
                    descriptors: []
                ),
                GATTAttribute.Characteristic(
                    uuid: GATTModelNumber.uuid,
                    value: GATTModelNumber(rawValue: model).data,
                    permissions: [.read],
                    properties: [.read],
                    descriptors: []
                ),
                GATTAttribute.Characteristic(
                    uuid: GATTSoftwareRevisionString.uuid,
                    value: GATTSoftwareRevisionString(rawValue: softwareVersion).data,
                    permissions: [.read],
                    properties: [.read],
                    descriptors: []
                ),
                GATTAttribute.Characteristic(
                    uuid: GATTSerialNumberString.uuid,
                    value: GATTSerialNumberString(rawValue: serialNumber).data,
                    permissions: [.read],
                    properties: [.read],
                    descriptors: []
                ),
            ]
        )
        
        _ = try await self.server.peripheral.add(service: gattInformation)
    }
    
    public func refresh() async throws {
                
        // update battery service
        await server.update(SolarBatteryService.self) {
            $0.refresh()
        }
        
        await server.update(OutletService.self) {
            $0.powerState = powerState
        }
    }
}

// MARK: - Methods

private extension SolarBatteryService {
    
    mutating func refresh() {
        // Start or stop charging
        if batteryLevel == 0 {
            chargingState = .charging
        } else if batteryLevel == 100 {
            chargingState = .notCharging
        }
        // increase or decrease battery charge
        switch chargingState {
        case .charging:
            batteryLevel += 1
            batteryChargingCurrent = 2
        case .notCharging:
            batteryLevel -= 1
            batteryChargingCurrent = 0
        case .notChargeable:
            break
        }
        // update state
        batteryVoltage = (Float(batteryLevel) / 100.0) * 24.0
        statusLowBattery = Float(batteryLevel) <= 20.0 ? .low : .normal
        
        // log
        print("Battery Level: \(batteryLevel)%")
    }
}

// MARK: - BluetoothAccessoryServerDelegate

extension SolarBluetoothServer: BluetoothAccessoryServerDelegate {
       
    public var cryptoHash: Nonce {
        get async {
            await self.authentication.cryptoHash
        }
    }
    
    public nonisolated func log(_ message: String) {
        print("Accessory:", message)
    }
    
    public nonisolated func didAdvertise(beacon: BluetoothAccessory.AccessoryBeacon) { }
    
    public func key(for id: UUID) async -> KeyData? {
        await self.authenticationDelegate.secret(for: id)
    }
    
    public func willRead(_ handle: UInt16, authentication authenticationMessage: AuthenticationMessage?) async -> Bool {
        return true
    }
    
    public func willWrite(_ handle: UInt16, authentication: BluetoothAccessory.AuthenticationMessage?) async -> Bool {
        return true
    }
    
    public func didWrite(_ handle: UInt16, authentication authenticationMessage: AuthenticationMessage?) async {
        
        switch handle {
        case await information.$identify.handle:
            if await information.identify {
                guard let authenticationMessage = authenticationMessage,
                      let key = await authenticationDelegate.key(for: authenticationMessage.id) else {
                    assertionFailure()
                    return
                }
                log("Did identify with key \(key.name)")
                lastIdentify = (key.id, Date())
                // clear value
                await self.server.update(InformationService.self) {
                    $0.identify = false
                }
            }
        case await outlet.$powerState.handle:
            guard let authenticationMessage = authenticationMessage,
                  let key = await authenticationDelegate.key(for: authenticationMessage.id) else {
                assertionFailure()
                return
            }
            let powerState = await self.outlet.powerState
            log("Did turn \(powerState ? "on" : "off") with key \(key.name)")
            
        case await authentication.$setup.handle:
            //assert(await authentication.$setup.value == characteristicValue)
            guard let authenticationMessage = authenticationMessage,
                  let request = await authentication.setup else {
                assertionFailure()
                return
            }
            // create new owner key
            guard await authenticationDelegate.setup(request, authenticationMessage: authenticationMessage) else {
                assertionFailure()
                return
            }
            log("Setup owner key for \(request.name)")
            // clear value
            let newKeysValue = await self.authenticationDelegate.allKeys
            await self.server.update(AuthenticationService.self) {
                $0.setup = nil
                $0.keys = newKeysValue
            }
        
        case await authentication.$createKey.handle:
            guard let request = await authentication.createKey,
                let authenticationMessage = authenticationMessage else {
                assertionFailure()
                return
            }
            // create a new key
            guard await authenticationDelegate.create(request, authenticationMessage: authenticationMessage) else {
                assertionFailure()
                return
            }
            // update db
            let newKeysValue = await self.authenticationDelegate.allKeys
            await self.server.update(AuthenticationService.self) {
                $0.createKey = nil
                $0.keys = newKeysValue
            }
        case await authentication.$confirmKey.handle:
            guard let request = await authentication.confirmKey,
                  let authenticationMessage = authenticationMessage else {
                assertionFailure()
                return
            }
            // confirm key
            guard await authenticationDelegate.confirm(request, authenticationMessage: authenticationMessage) else {
                assertionFailure()
                return
            }
            // update db
            let newKeysValue = await self.authenticationDelegate.allKeys
            await self.server.update(AuthenticationService.self) {
                $0.createKey = nil
                $0.keys = newKeysValue
            }
        default:
            break
        }
    }
    
    public func updateCryptoHash() async {
        await self.server.update(AuthenticationService.self) {
            $0.cryptoHash = Nonce()
        }
    }
}

internal extension SolarBluetoothServer {
    
    nonisolated var authentication: AuthenticationService {
        get async {
            await server[AuthenticationService.self]
        }
    }
    
    nonisolated var information: InformationService {
        get async {
            await server[InformationService.self]
        }
    }
    
    nonisolated var outlet: OutletService {
        get async {
            await server[OutletService.self]
        }
    }
        
    nonisolated var battery: SolarBatteryService {
        get async {
            await server[SolarBatteryService.self]
        }
    }
}

#endif
