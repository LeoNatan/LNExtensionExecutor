# LNExtensionExecutor
An extension executor for iOS, allowing bypass of `UIActivityViewController` to execute both UI and non-UI action extensions directly. It is up to you to figure out what the bundle identifier of the extension is.

### Usage

Import `LNExtensionExecutor.h` and `LNExtensionExecutor.m` in your project. You can then use `LNExtensionExecutor`.

In the following example, the WhatsApp share extension is opened with an image:

```swift
let executor = LNExtensionExecutor(extensionBundleIdentifier: "net.whatsapp.WhatsApp.ShareExtension")
executor?.execute(withInputItems: [UIImage(systemName: "scribble.variable")!], on: self, completionHandler: { completed, returnedItems, activityError in
	guard let activityError = activityError else {
		return
	}
	
	print("Got error: \(activityError)")
})
```

