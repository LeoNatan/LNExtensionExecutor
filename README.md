# LNExtensionExecutor

An extension executor for iOS, allowing bypass of `UIActivityViewController` to execute both UI and non-UI action extensions directly.

[![GitHub release](https://img.shields.io/github/release/LeoNatan/LNExtensionExecutor.svg)](https://github.com/LeoNatan/LNExtensionExecutor/releases) [![GitHub stars](https://img.shields.io/github/stars/LeoNatan/LNExtensionExecutor.svg)](https://github.com/LeoNatan/LNExtensionExecutor/stargazers) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/LeoNatan/LNExtensionExecutor/master/LICENSE) <span class="badge-paypal"><a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BR68NJEJXGWL6" title="Donate to this project using PayPal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg?style=flat" alt="PayPal Donation Button" /></a></span>

[![GitHub issues](https://img.shields.io/github/issues-raw/LeoNatan/LNExtensionExecutor.svg)](https://github.com/LeoNatan/LNExtensionExecutor/issues) [![GitHub contributors](https://img.shields.io/github/contributors/LeoNatan/LNExtensionExecutor.svg)](https://github.com/LeoNatan/LNExtensionExecutor/graphs/contributors) ![](https://img.shields.io/badge/swift%20package%20manager-compatible-green)

## Adding to Your Project

Swift Package Manager is the recommended way to integrate `LNExtensionExecutor` in your project.

`LNExtensionExecutor` supports SPM versions 5.1.0 and above. To use SPM, you should use Xcode 11 to open your project. Click `File` -> `Swift Packages` -> `Add Package Dependency`, enter `https://github.com/LeoNatan/LNExtensionExecutor`. Select the version you’d like to use.

You can also manually add the package to your Package.swift file:

```swift
.package(url: "https://github.com/LeoNatan/LNExtensionExecutor.git", from: "1.0")
```

And the dependency in your target:

```swift
.target(name: "BestExampleApp", dependencies: ["LNExtensionExecutor"]),
```

## Usage

In the following example, the WhatsApp share extension is opened with an image:

```swift
import LNExtensionExecutor

//...

do {
	let executor = try LNExtensionExecutor(extensionBundleIdentifier: "net.whatsapp.WhatsApp.ShareExtension")
	let (completed, returnItems) = try await executor.execute(withActivityItems: activityItems, on: self)
	print("completed: \(completed) return items: \(returnItems)")
} catch(let error) {
	print("error: \(error.localizedDescription)")
}
```

The activity items provided to the `execute` method should be the same that would be passed to a `UIActivityViewController` instance.

## Extension Bundle Identifier Discovery

It is up to you to figure out what the bundle identifier of the extension is. One approach to discovering them is by using `UIActivityViewController` and setting the `completionWithItemsHandler` property with a closure, and printing the `activityType` argument. Note, that, in some cases, the activity type differs from the bundle identifier of the extension. Another approach is to obtain an IPA from the App Store or accessing the filesystem in a jailbroken device, and inspecting the Info.plist of the extension for the bundle identifier. 
