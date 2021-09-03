//
//  ViewController.swift
//  LNExtensionExecutorExample
//
//  Created by Leo Natan on 2/26/21.
//

import UIKit
import LNExtensionExecutor

class ViewController: UIViewController {
	fileprivate var payload: [Any] {
		return [UIImage(systemName: "scribble.variable")!]
	}
	
	fileprivate func execute(extensionBundleIdentifier: String) {
		do {
			let executor = try LNExtensionExecutor(extensionBundleIdentifier: extensionBundleIdentifier)
			executor.execute(withInputItems: payload, on: self, completionHandler: { completed, returnedItems, activityError in
				guard let activityError = activityError else {
					return
				}
				
				print("Got error: \(activityError)")
			})
		} catch(let error) {
			print(error.localizedDescription)
		}
	}
	
	@IBAction func showWhatsApp(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: "net.whatsapp.WhatsApp.ShareExtension")
	}
	
	@IBAction func showInstagram(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: "com.burbn.instagram.shareextension")
	}
	
	@IBAction func showNotes(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: "com.apple.mobilenotes.SharingExtension")
	}
	
	@IBAction func showActivityViewController(_ sender: AnyObject) {
		let avc = UIActivityViewController(activityItems: payload, applicationActivities: nil)
		present(avc, animated: true)
	}
}
