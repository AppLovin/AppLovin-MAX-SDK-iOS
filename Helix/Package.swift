// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
// this is local package for testing purposes
import PackageDescription

let package = Package(
    name: "VoodooMaxAdapter",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [ Constants.mainProduct ],
    dependencies: [Constants.appLovinDependency, Constants.voodooLocalPackage],
    targets: [Constants.mainTarget]
)

private enum Constants {
    static var appLovinPackage: PackageDescription.Target.Dependency {
        .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package")
    }
    static var appLovinDependency: Package.Dependency {
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", .upToNextMajor(from: "13.0.0"))
    }

    static var voodooLocalPackage: Package.Dependency {
        .package(path: "../../VoodooAdn")
    }

    static var mainTarget: PackageDescription.Target {
        .target(
            name: "VoodooMaxAdapter",
            dependencies: [
                Self.appLovinPackage,
                "VoodooAdn"
            ],
            path: "Sources"
        )
    }

    static var mainProduct: Product {
        .library(
            name: "VoodooMaxAdapter",
            targets: ["VoodooMaxAdapter"])
    }
}
