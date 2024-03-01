//
//  SolarAccessory.swift
//
//
//  Created by Alsey Coleman Miller on 3/1/24.
//

#if os(Linux)
import Glibc
import BluetoothLinux
#elseif os(macOS)
import Darwin
import CoreBluetooth
import DarwinGATT
#endif

import Foundation
import CoreFoundation
import Dispatch
import ArgumentParser
import Bluetooth
import GATT
import BluetoothAccessory
import BluetoothAccessoryExample

#if os(Linux)
typealias LinuxCentral = GATTCentral<BluetoothLinux.HostController, BluetoothLinux.L2CAPSocket>
typealias LinuxPeripheral = GATTPeripheral<BluetoothLinux.HostController, BluetoothLinux.L2CAPSocket>
typealias NativeCentral = LinuxCentral
typealias NativePeripheral = LinuxPeripheral
#elseif os(macOS)
typealias NativeCentral = DarwinCentral
typealias NativePeripheral = DarwinPeripheral
#else
#error("Unsupported platform")
#endif

@main
struct SolarBluetoothTool: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "Example deamon for a Bluetooth LE Solar Inverter Device.",
        version: "1.0.0"
    )
    
    @Option(help: "The path to the configuration file.")
    var configuration: String = "configuration.json"
    
    @Option(help: "The path to the authentication file.")
    var authentication: String = "authentication.json"
    
    @Option(help: "The interval (in seconds) at which data is refreshed.")
    var refreshInterval: Int = 1
    
    private static var server: SolarBluetoothServer<NativePeripheral, AuthenticationManager>!
    
    private static let fileManager = FileManager()
    
    func validate() throws {
        guard refreshInterval >= 1 else {
            throw ValidationError("<refresh-interval> must be at least 1 second.")
        }
    }
    
    func run() throws {
        
        // read configuration first
        let configuration = try loadConfiguration()
        
        #if DEBUG
        printConfiguration(configuration)
        #endif
        
        // start async code
        Task {
            do {
                try await start(with: configuration)
            }
            catch {
                fatalError("\(error)")
            }
        }
        // run main loop
        RunLoop.current.run()
    }
    
    private func start(with configuration: AccessoryConfiguration) async throws {
        
        // load authentication
        let authentication = AuthenticationManager(
            configurationURL: Self.url(for: self.configuration),
            authenticationURL: Self.url(for: self.authentication)
        )
        
        // print pairing code
        if await authentication.isConfigured == false {
            print("Pairing:", AccessoryURL.setup(configuration.id, configuration.setupSecret))
        }
        
        // load Bluetooth
        let peripheral = try await loadBluetooth()
        
        // publish GATT server, enable advertising
        Self.server = try await SolarBluetoothServer(
            peripheral: peripheral,
            id: configuration.id,
            rssi: configuration.rssi,
            model: configuration.model,
            serialNumber: configuration.id.description,
            softwareVersion: SolarBluetoothTool.configuration.version,
            refreshInterval: TimeInterval(refreshInterval),
            authentication: authentication
        )
    }
    
    static func url(for path: String) -> URL {
        let url: URL
        if path.contains("/") {
            url = URL(fileURLWithPath: path)
        } else {
            let currentDirectory = FileManager.default.currentDirectoryPath
            url = URL(fileURLWithPath: currentDirectory).appendingPathComponent(path)
        }
        return url
    }
    
    func loadConfiguration() throws -> AccessoryConfiguration {
        
        let fileURL = Self.url(for: self.configuration)
        if Self.fileManager.fileExists(atPath: fileURL.path) {
            let configuration = try AccessoryConfiguration(url: fileURL)
            #if DEBUG
            print("Loaded configuration at \(fileURL.path)")
            #endif
            return configuration
        } else {
            let configuration = AccessoryConfiguration(rssi: 0, model: "MPPT-1001") // default value
            let data = try configuration.encode()
            let didCreate = Self.fileManager.createFile(atPath: fileURL.path, contents: data)
            precondition(didCreate)
            #if DEBUG
            print("Created configuration at \(fileURL.path)")
            #endif
            return configuration
        }
    }
    
    func printConfiguration(_ configuration: AccessoryConfiguration) {
        print("ID: \(configuration.id)")
    }
    
    func loadBluetooth() async throws -> NativePeripheral {
        
        // TODO: Specify HCI device
        
        #if os(Linux)
        guard let hostController = await HostController.default else {
            throw CommandError.bluetoothUnavailable
        }
        let address = try await hostController.readDeviceAddress()
        NSLog("Bluetooth Controller: \(address)")
        let serverOptions = GATTPeripheralOptions(
            maximumTransmissionUnit: .max,
            maximumPreparedWrites: 1000
        )
        let peripheral = LinuxPeripheral(
            hostController: hostController,
            options: serverOptions,
            socket: BluetoothLinux.L2CAPSocket.self
        )
        #elseif os(macOS)
        let peripheral = DarwinPeripheral(
            options: .init(
                showPowerAlert: true,
                restoreIdentifier: "com.colemancda.solar-bluetooth"
            )
        )
        #endif
        
        peripheral.log = { NSLog("Peripheral: \($0)") }
        
        #if os(macOS)
        // wait till power on
        try await peripheral.waitPowerOn()
        #endif
        
        return peripheral
    }
}
