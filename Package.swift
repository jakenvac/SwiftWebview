// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "SwiftWebview",
    products: [
        .library(
            name: "SwiftWebview",
            targets: ["SwiftWebview"]
        ),
    ],
    targets: [
        .target(
            name: "cWebview",
            path: "Sources/cWebview"
        ),
        .target(
            name: "SwiftWebview",
            dependencies: ["cWebview"]
        ),
        .testTarget(
            name: "SwiftWebviewTests",
            dependencies: ["SwiftWebview"]
        ),
    ],
    cxxLanguageStandard: .cxx11
)
