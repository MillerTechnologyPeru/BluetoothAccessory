// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BluetoothAccessory",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "BluetoothAccessory",
            targets: ["BluetoothAccessory"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .upToNextMajor(from: "6.0.0")
        ),
        .package(
            url: "https://github.com/PureSwift/TLVCoding.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            branch: "master"
        )
    ],
    targets: [
        .target(
            name: "BluetoothAccessory",
            dependencies: [
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
                "TLVCoding"
            ]
        ),
        .testTarget(
            name: "BluetoothAccessoryTests",
            dependencies: ["BluetoothAccessory"]
        ),
    ]
)
