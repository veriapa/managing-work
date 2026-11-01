// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DeskClock",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "DeskClock", targets: ["DeskClock"]),
        .executable(name: "DeskClockLoginItem", targets: ["DeskClockLoginItem"])
    ],
    targets: [
        .executableTarget(name: "DeskClock"),
        .executableTarget(name: "DeskClockLoginItem")
    ]
)
