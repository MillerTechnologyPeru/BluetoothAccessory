// swift-tools-version:5.7
import PackageDescription

let bluetoothDependencies: [Target.Dependency] = [
    "BluetoothAccessory",
    .product(
        name: "Bluetooth",
        package: "Bluetooth"
    ),
    .product(
        name: "BluetoothGATT",
        package: "Bluetooth",
        condition: .when(platforms: [.macOS, .linux])
    ),
    .product(
        name: "BluetoothHCI",
        package: "Bluetooth",
        condition: .when(platforms: [.macOS, .linux])
    ),
    .product(
        name: "BluetoothGAP",
        package: "Bluetooth",
        condition: .when(platforms: [.macOS, .linux])
    ),
    .product(
        name: "GATT",
        package: "GATT"
    ),
    .product(
        name: "DarwinGATT",
        package: "GATT",
        condition: .when(platforms: [.macOS])
    ),
    .product(
        name: "BluetoothLinux",
        package: "BluetoothLinux",
        condition: .when(platforms: [.linux])
    ),
    .product(
        name: "ArgumentParser",
        package: "swift-argument-parser"
    )
]

let package = Package(
    name: "BluetoothAccessory-Sample",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "BulbAccessory",
            targets: ["BulbAccessory"]
        ),
        .executable(
            name: "LockAccessory",
            targets: ["LockAccessory"]
        ),
        .executable(
            name: "ThermostatAccessory",
            targets: ["ThermostatAccessory"]
        ),
        .executable(
            name: "SolarAccessory",
            targets: ["SolarAccessory"]
        )
    ],
    dependencies: [
        .package(
            name: "BluetoothAccessory",
            path: "../"
        ),
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .upToNextMajor(from: "6.0.0")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothLinux.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.2.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "BulbAccessory",
            dependencies: bluetoothDependencies + ["BluetoothAccessoryExample"]
        ),
        .executableTarget(
            name: "LockAccessory",
            dependencies: bluetoothDependencies + ["BluetoothAccessoryExample"]
        ),
        .executableTarget(
            name: "ThermostatAccessory",
            dependencies: bluetoothDependencies + ["BluetoothAccessoryExample"]
        ),
        .executableTarget(
            name: "SolarAccessory",
            dependencies: bluetoothDependencies + ["BluetoothAccessoryExample"]
        ),
        .target(
            name: "BluetoothAccessoryExample",
            dependencies: bluetoothDependencies
        )
    ]
)
