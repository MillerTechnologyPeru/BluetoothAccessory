//
//  AccessoryCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/10/23.
//

import Foundation
import Bluetooth
import GATT
#if canImport(BluetoothGATT)
import BluetoothGATT
#endif

/// Bluetooth Accessory Characteristic
public protocol AccessoryCharacteristic {
    
    associatedtype Value: CharacteristicCodable
    
    static var type: BluetoothUUID { get }
    
    static var name: String { get }
    
    static var properties: BitMaskOptionSet<CharacteristicProperty> { get }
    
    static var unit: CharacteristicUnit? { get }
    
    init(value: Value)
    
    var value: Value { get }
}

public extension AccessoryCharacteristic {
    
    static var name: String { CharacteristicType(uuid: self.type)?.description ?? self.type.description }
    
    static var unit: CharacteristicUnit? { nil }
    
    static var format: CharacteristicFormat { Value.characteristicFormat }
}

extension AccessoryCharacteristic where Self.Value: CustomStringConvertible {
    
    public var description: String {
        value.description
    }
}

public extension AccessoryCharacteristic {
    
    init?(from data: Data) {
        guard let characteristicValue = CharacteristicValue(from: data, format: Value.characteristicFormat),
              let value = Value(characteristicValue: characteristicValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    func encode() -> Data {
        value.characteristicValue.encode()
    }
}

public extension AccessoryCharacteristic {
    
    static var descriptors: [AccessoryDescriptor] {
        var descriptors: [AccessoryDescriptor] = [
            .properties(properties),
            .format(Value.characteristicFormat)
        ]
        if let unit = self.unit {
            descriptors.append(.unit(unit))
        }
        return descriptors
    }
}

#if canImport(BluetoothGATT)
internal extension AccessoryCharacteristic {
    
    static var gattProperties: Bluetooth.BitMaskOptionSet<GATTAttribute.Characteristic.Property> {
        var properties = Bluetooth.BitMaskOptionSet<GATTAttribute.Characteristic.Property>()
        if self.properties.contains(.read) {
            properties.insert(.read)
        }
        if self.properties.contains(.list) || self.properties.contains(.notification) {
            properties.insert(.notify)
        }
        if self.properties.contains(.write) {
            properties.insert(.write)
        }
        if self.properties.contains(.writeWithoutResponse) {
            properties.insert(.writeWithoutResponse)
        }
        return properties
    }
    
    static var gattPermissions: Bluetooth.BitMaskOptionSet<GATTAttribute.Characteristic.Permission> {
        var permissions = Bluetooth.BitMaskOptionSet<GATTAttribute.Characteristic.Permission>()
        if self.properties.contains(.read) {
            permissions.insert(.read)
        }
        if self.properties.contains(.write) {
            permissions.insert(.write)
        }
        return permissions
    }
    
    static var gattDescriptors: [GATTAttribute.Descriptor] {
        var descriptors = self.descriptors.map({ .init($0) })
            + [GATTUserDescription(userDescription: self.name).descriptor]
        // unencrypted values
        if !(self.properties.contains(.encrypted) || self.properties.contains(.list)) {
            descriptors.append(GATTFormatDescriptor(format: .init(bluetoothAccessory: Value.characteristicFormat), exponent: 0, unit: 0, namespace: 0, description: 0).descriptor)
        }
        // notifications
        if gattProperties.contains(.notify) {
            descriptors.append(GATTClientCharacteristicConfiguration().descriptor)
        }
        return descriptors
    }
}

public extension GATTAttribute.Characteristic {
    
    init<T: AccessoryCharacteristic>(_ characteristic: T.Type) {
        self.init(
            uuid: characteristic.type,
            value: Data(),
            permissions: characteristic.gattPermissions,
            properties: characteristic.gattProperties,
            descriptors: characteristic.gattDescriptors
        )
    }
}

public extension PeripheralManager {
    
    func add<Service: AccessoryService>(
        service: Service.Type,
        with characteristics: [any AccessoryCharacteristic.Type]
    ) async throws -> (UInt16, [UInt16]) {
        let characteristicAttributes = characteristics.map {
            GATTAttribute.Characteristic(
                uuid: $0.type,
                value: Data(),
                permissions: $0.gattPermissions,
                properties: $0.gattProperties,
                descriptors: $0.gattDescriptors
            )
        }
        let serviceAttribute = GATTAttribute.Service(
            uuid: service.type,
            primary: true,
            characteristics: characteristicAttributes,
            includedServices: []
        )
        return try await self.add(service: serviceAttribute)
    }
}
#endif
