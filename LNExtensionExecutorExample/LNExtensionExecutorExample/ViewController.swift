//
//  ViewController.swift
//  LNExtensionExecutorExample
//
//  Created by Leo Natan on 2/26/21.
//

import UIKit

class ViewController: UIViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let executor = LNExtensionExecutor(extensionBundleIdentifier: "net.whatsapp.WhatsApp.ShareExtension")
		executor?.execute(withInputItems: [UIImage(systemName: "scribble.variable")!], on: self, completionHandler: { completed, returnedItems, activityError in
			guard let activityError = activityError else {
				return
			}
			
			print("Got error: \(activityError)")
		})
	}
}
