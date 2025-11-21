//
//  ViewController.swift
//  LNExtensionExecutorExample
//
//  Created by Leo Natan on 2/26/21.
//

import UIKit
import LNExtensionExecutor

class ViewController: UIViewController {
	fileprivate let payload: [Any] = ["Some text", UIImage(systemName: "scribble.variable")!]

	@ViewLoading @IBOutlet
	var stackView: UIStackView

	@ViewLoading @IBOutlet
	var customActivityTextField: UITextField
	@ViewLoading @IBOutlet
	var customButton: UIButton
	@ViewLoading @IBOutlet
	var shareButton: UIButton

	override func viewDidLoad() {
		super.viewDidLoad()

		NSLayoutConstraint.activate([
			view.keyboardLayoutGuide.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: customButton.bottomAnchor, multiplier: 1.0)
		])

		if #available(iOS 26.0, *) {
			var config = UIButton.Configuration.prominentClearGlass()
			config.image = UIImage(systemName: "doc.on.doc")
			shareButton.configuration = config

			NSLayoutConstraint.activate([
				shareButton.widthAnchor.constraint(equalToConstant: 44),
				shareButton.heightAnchor.constraint(equalToConstant: 44),
			])
		}

		NotificationCenter.default.addObserver(forName: Notification.Name("lastSelectedActivityType"), object: nil, queue: .main) { [weak self] n in
			guard let type = n.object as? String else {
				return
			}

			self?.customActivityTextField.text = type
			self?.updateCustomButtons()
		}

		NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: customActivityTextField, queue: .main) { [weak self] n in
			self?.updateCustomButtons()
		}
	}

	@IBAction
	func endEditing() {
		customActivityTextField.resignFirstResponder()
	}

	func updateCustomButtons() {
		customButton.isEnabled = customActivityTextField.text != nil && customActivityTextField.text.unsafelyUnwrapped.isEmpty == false
		shareButton.isEnabled = customActivityTextField.text != nil && customActivityTextField.text.unsafelyUnwrapped.isEmpty == false
	}

	@MainActor
	fileprivate func execute(extensionBundleIdentifier: String) async {
		do {
			let executor = try LNExtensionExecutor(extensionIdentifier: extensionBundleIdentifier)
			let (completed, returnItems) = try await executor.execute(withActivityItems: payload, on: self)
			print("completed: \(completed) return items: \(returnItems)")
		} catch(let error) {
			print("error: \(error.localizedDescription)")
			let alert = UIAlertController(title: "LNExtensionExecutor Error", message: error.localizedDescription, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
		}
	}
	
	fileprivate func execute(extensionBundleIdentifier: String) {
		Task {
			await execute(extensionBundleIdentifier: extensionBundleIdentifier)
		}
	}
	
	@IBAction func showMail(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: UIActivity.ActivityType.mail.rawValue)
	}
	
	@IBAction func showMessage(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: UIActivity.ActivityType.message.rawValue)
	}

	@IBAction func showPrint(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: UIActivity.ActivityType.print.rawValue)
	}

	@IBAction func showWhatsApp(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: "net.whatsapp.WhatsApp.ShareExtension")
	}

	@IBAction func showTwatter(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: "com.apple.share.Twitter.post")
	}

	@IBAction func showInstagram(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: "com.burbn.instagram.shareextension")
	}
	
	@IBAction func showNotes(_ sender: AnyObject) {
		execute(extensionBundleIdentifier: "com.apple.mobilenotes.SharingExtension")
	}

	@IBAction func showCustom(_ sender: AnyObject) {
		guard let type = customActivityTextField.text, type.isEmpty == false else {
			return
		}

		execute(extensionBundleIdentifier: type)
	}

	@IBAction func showActivityViewController(_ sender: AnyObject) {
		let avc = SpyActivityViewController(activityItems: payload, applicationActivities: nil)
		avc.popoverPresentationController?.sourceView = sender as? UIView
		present(avc, animated: true)
	}
}

extension ViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		updateCustomButtons()
		if customButton.isEnabled {
			showCustom(customButton)
		}
		return false
	}

	@IBAction
	func shareCustomActivityIdentifier(_ sender: AnyObject) {
		guard let identifier = customActivityTextField.text, identifier.isEmpty == false else {
			return
		}

		UIPasteboard.general.string = identifier
	}
}
