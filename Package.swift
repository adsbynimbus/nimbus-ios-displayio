// swift-tools-version: 6.1

import PackageDescription

var package = Package(
    name: "NimbusDisplayIOKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
           name: "NimbusDisplayIOKit",
           targets: ["NimbusDisplayIOKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/displayio/DIOSDK", from: "4.7.5")
    ],
    targets: [
        .target(
            name: "NimbusDisplayIOKit",
            dependencies: [
                .product(name: "NimbusKit", package: "nimbus-ios-sdk"),
                .product(name: "DIOSDK-WithoutFBAudienceNetwork", package: "DIOSDK")
            ]
        ),
        .testTarget(
            name: "NimbusDisplayIOKitTests",
            dependencies: ["NimbusDisplayIOKit"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

package.dependencies.append(.package(url: "https://github.com/adsbynimbus/nimbus-ios-sdk", from: "3.0.0-rc.2"))
