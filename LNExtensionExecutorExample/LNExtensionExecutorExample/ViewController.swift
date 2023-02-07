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
	
	@MainActor
	fileprivate func execute(extensionBundleIdentifier: String) async {
		do {
			let executor = try LNExtensionExecutor(extensionBundleIdentifier: extensionBundleIdentifier)
			let (completed, returnItems) = try await executor.execute(withActivityItems: payload, on: self)
			print("completed: \(completed) return items: \(returnItems)")
		} catch(let error) {
			print("error: \(error.localizedDescription)")
		}
	}
	
	fileprivate func execute(extensionBundleIdentifier: String) {
		Task {
			await execute(extensionBundleIdentifier: extensionBundleIdentifier)
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
		avc.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
			guard let activityType else {
				return
			}
			
			print("🔵 Activity type: \(activityType.rawValue) completed: \(completed)")
		}
		present(avc, animated: true)
	}
}
