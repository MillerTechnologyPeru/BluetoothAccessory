//
//  Model.swift
//  BluetoothAccessoryKit
//
//  Created by Alsey Coleman Miller on 9/25/23.
//

import Foundation
import CoreModel

public extension Model {
    
    static var bluetoothAccessory: Model {
        Model(entities: 
              AccessoryEntity.self,
              CharacteristicEntity.self,
              CharacteristicValueEntity.self,
              KeyEntity.self,
              NewKeyEntity.self
        )
    }
}
