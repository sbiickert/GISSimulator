//
//  DocumentViewController.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-23.
//

import UIKit

class DocumentViewController: UIDocumentViewController,
							  UIDocumentBrowserViewControllerDelegate,
							  UITextViewDelegate, UITextFieldDelegate {
	var designDoc: Document? {
		return document as? Document
	}
	
	@IBAction func nameChanged(_ sender: UITextField) {
		textFieldDidEndEditing(sender)
	}
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var button: UIButton!
	@IBOutlet weak var descriptionTextView: UITextView!
	
	@IBAction func buttonClicked(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let mainVC = storyboard.instantiateInitialViewController() as! MainVC
		navigationController?.pushViewController(mainVC, animated: true)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let oldName = designDoc?.data.design.name {
			designDoc!.data.design.name = textField.text ?? ""
			document?.undoManager?.registerUndo(withTarget: designDoc!) {
				$0.data.design.name = oldName
			}
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if let oldDesc = designDoc?.data.design.description {
			designDoc!.data.design.description = textView.text
			document?.undoManager?.registerUndo(withTarget: designDoc!) {
				$0.data.design.description = oldDesc
			}
		}
	}
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		descriptionTextView.layer.cornerRadius = 8
		descriptionTextView.layer.borderWidth = 1.0
		descriptionTextView.layer.borderColor = UIColor.systemGray.cgColor
	}
	
	override func documentDidOpen() {
		super.documentDidOpen()
		print("Document named \(document?.localizedName ?? "err") opened")
		nameTextField.text = designDoc?.data.design.name
		descriptionTextView.text = designDoc?.data.design.description
	}
	

}
