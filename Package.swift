// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Convenient Concurrency",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Convenient Concurrency",
      targets: ["Convenient Concurrency"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble", from: "12.0.0"),
    .package(url: "https://github.com/Quick/Quick", from: "7.0.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Convenient Concurrency"
    ),
    .testTarget(
      name: "Convenient Concurrency Tests",
      dependencies: ["Convenient Concurrency", "Nimble", "Quick"]
    )
  ]
)

let packageVersion: Version = "1.0.0"
