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
        .systemLibrary(
            name: "cWebkit2gtk",
            pkgConfig: "webkit2gtk-4.0",
            providers: [
                .apt(["libwebkit2gtk-4.0-dev"]),
            ]
        ),
        .target(
            name: "cWebview",
            dependencies: [
                .target(
                    name: "cWebkit2gtk",
                    condition: .when(
                        platforms: [.linux]
                    )
                ),
            ],
            path: "Sources/cWebview",
            linkerSettings: [
                .linkedFramework(
                    "WebKit",
                    .when(platforms: [.macOS])
                ),
            ]
        ),
        .target(
            name: "SwiftWebview",
            dependencies: ["cWebview"]
        ),
    ],
    cxxLanguageStandard: .cxx11
)
