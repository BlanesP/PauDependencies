// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PauDependencies",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PauDependencies",
            targets: ["PauDependencies"]
        ),
        .library(name: "PauDependenciesTestSupport", targets: ["PauDependenciesTestSupport"]),
        .library(name: "PauDependenciesQuickSupport", targets: ["PauDependenciesQuickSupport"])
    ],
    traits: [
        .trait(name: "QuickTrait", enabledTraits: []),
        .default(enabledTraits: [])          // QuickTrait is opt-in (off by default)
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PauDependencies",
            dependencies: [
                .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "PauDependenciesTestSupport",
            dependencies: ["PauDependencies"]
        ),
        .target(
            name: "PauDependenciesQuickSupport",
            dependencies: [
                "PauDependencies",
                .product(name: "Quick", package: "Quick", condition: .when(traits: ["QuickTrait"]))
            ]
        ),
        .testTarget(
            name: "PauDependenciesTests",
            dependencies: [
                "PauDependenciesTestSupport",
                "PauDependenciesQuickSupport",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
