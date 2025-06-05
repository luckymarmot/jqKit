// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "macOSjqKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "macOSjqKit",
            targets: ["macOSjqKit"]
        ),
    ],
    targets: [
        .target(
            name: "macOSjqKit",
            dependencies: ["libjq", "onig"],
            path: "jqKit",
            sources: ["LMJqFilter.m"],
            publicHeadersPath: "."
        ),
        .binaryTarget(
            name: "libjq",
            path: "jqKit/lib/libjq.xcframework"
        ),
        .binaryTarget(
            name: "onig",
            path: "jqKit/lib/onig.xcframework"
        ),
        .testTarget(
            name: "jqKitTests",
            dependencies: ["macOSjqKit"],
            path: "jqKitTests",
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
