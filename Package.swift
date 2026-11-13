// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "mobile_project",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "mobile_project",
            targets: ["mobile_project"]
        ),
    ],
    targets: [
        .target(
            name: "mobile_project",
            path: ".",
            sources: ["Models", "Services"]
        ),
        .testTarget(
            name: "mobile_projectTests",
            dependencies: ["mobile_project"],
            path: "Tests"
        )
    ]
)
