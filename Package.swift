// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

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
        .library(
            name: "PauDependenciesMacros",
            targets: ["PauDependenciesMacros"]
        ),
        .library(
            name: "PauDependenciesTestSupport",
            targets: ["PauDependenciesTestSupport"]
        ),
        .library(
            name: "PauDependenciesQuickSupport",
            targets: ["PauDependenciesQuickSupport"]
        )
    ],
    traits: [
        .trait(name: "QuickTrait", enabledTraits: []),
        .trait(name: "SwiftSyntaxTrait", enabledTraits: []),
        .default(enabledTraits: [])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.5.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0")
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
        .target(
            name: "PauDependenciesMacros",
            dependencies: [
                .target(name: "PauDependenciesMacrosPlugin",
                        condition: .when(traits: ["SwiftSyntaxTrait"]))
            ]
        ),
        .macro(
            name: "PauDependenciesMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax", condition: .when(traits: ["SwiftSyntaxTrait"])),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax", condition: .when(traits: ["SwiftSyntaxTrait"])),
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
