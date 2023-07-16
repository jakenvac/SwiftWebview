// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-webview",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-webview",
            targets: ["swift-webview"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "cWebview",
            path: "Sources/cWebview"
        ),
        .target(
            name: "swift-webview",
            dependencies: ["cWebview"]
        ),
        .testTarget(
            name: "swift-webviewTests",
            dependencies: ["swift-webview"]
        ),
    ],
    cxxLanguageStandard: .cxx11
)
