// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Navio",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        // Navio
        .library(
            name: "Navio",
            targets: ["Navio"]
        ),
        
        // ToolBox
        .library(
            name: "ToolBox",
            targets: ["ToolBox"]
        )
    ],
    targets: [
        // Navio
        .target(
            name: "Navio",
            dependencies: ["ToolBox"]
        ),
        .testTarget(
            name: "NavioTests",
            dependencies: ["Navio", "ToolBox"]
        ),
        
        
        // ToolBox
        .target(
            name: "ToolBox"
        )
    ]
)
