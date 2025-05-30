// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AirPodsMonitor",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "AirPodsMonitor", targets: ["AirPodsMonitor"])
    ],
    targets: [
        .executableTarget(
            name: "AirPodsMonitor",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "AirPodsMonitorTests",
            dependencies: ["AirPodsMonitor"],
            path: "Tests"
        )
    ]
)