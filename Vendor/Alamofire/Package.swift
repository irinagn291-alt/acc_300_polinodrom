// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Alamofire",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Alamofire", targets: ["Alamofire"])
    ],
    targets: [
        .binaryTarget(name: "Alamofire", path: "../Alamofire.xcframework")
    ]
)
