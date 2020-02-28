// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Website",
    products: [
        .executable(name: "Website", targets: ["Website"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Website",
            dependencies: ["Publish"]
        )
    ]
)