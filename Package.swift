// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "LNExtensionExecutor",
	platforms: [
		.iOS(.v10)
	],
	products: [
		.library(
			name: "LNExtensionExecutor",
			type: .dynamic,
			targets: ["LNExtensionExecutor"]),
		.library(
			name: "LNExtensionExecutor-Static",
			type: .static,
			targets: ["LNExtensionExecutor"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "LNExtensionExecutor",
			dependencies: [],
			exclude: [
			],
			publicHeadersPath: "."
		),
	]
)
