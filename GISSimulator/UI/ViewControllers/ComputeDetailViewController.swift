//
//  ComputeDetailViewController.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-05-10.
//

import UIKit

class ComputeDetailViewController: UIViewController,
								   UITableViewDelegate,
								   UITableViewDataSource,
								   UITextFieldDelegate {
	
	var delegate: DetailViewControllerDelegate?
	
	private var design: Design? {
		VCUtil.getDesign(self)
	}
	
	var node: ComputeNode = ComputeNode(name: "", description: "", hardwareDefinition: DefLibManager.hardwareDefLib.hardware.first!.value, memoryGB: 8, zone: Zone(name: "", description: "", zoneType: .Secured), type: .PhysicalServer) {
		didSet {
			updateUI()
		}
	}
	
	var zone: Zone? {
		didSet {
			updateUI()
		}
	}
	
	var deletedNode: Bool = false

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var descTextField: UITextField!
	@IBOutlet weak var hardwareMenuButton: UIButton!
	@IBOutlet weak var memoryTextField: UITextField!
	@IBOutlet weak var memoryMenuButton: UIButton!
	@IBOutlet weak var zoneMenuButton: UIButton!
	@IBOutlet weak var typeMenuButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	
	@IBAction func nameChanged(_ sender: UITextField) {
	}
	@IBAction func descriptionChanged(_ sender: UITextField) {
	}
	@IBAction func hardwareMenuAction(_ sender: UIAction) {
		
	}

	@IBAction func memoryChanged(_ sender: UITextField) {
	}
	@IBAction func memoryMenuAction(_ sender: UIAction) {
		
	}
	@IBAction func zoneMenuAction(_ sender: UIAction) {
		
	}
	@IBAction func typeMenuAction(_ sender: UIAction) {
		
	}
	
	@IBAction func deleteButtonClicked(_ sender: Any) {
	}
	
	private func updateUI() {
		guard design != nil, nameTextField != nil else { return }
		nameTextField.text = node.name
		descTextField.text = node.description
		memoryTextField.text = String(node.memoryGB)
		if let selectedItem = hardwareMenuButton.menu!.children.first(where: { $0.title == node.hardwareDefinition.processor }) as? UIAction {
			selectedItem.state = .on
		}
		if let selectedItem = zoneMenuButton.menu!.children.first(where: { $0.title == zone?.name }) as? UIAction {
			selectedItem.state = .on
		}
		if let selectedItem = typeMenuButton.menu!.children.first(where: { $0.title == node.type.stringValue }) as? UIAction {
			selectedItem.state = .on
		}
		tableView.reloadData()
	}
	
	@objc func done() {
		delegate?.detailViewControllerDidDismiss(self)
		self.dismiss(animated: true)
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		// Create the Done button
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		navigationController?.navigationBar.isHidden = false

		// Set up the hardware popup menu.
		let hw = DefLibManager.hardwareDefLib.hardware.keys.sorted()
		let hardwareOptions: [UIAction] = hw.map({ UIAction(title: $0, handler: {[self] (action: UIAction) in
			self.hardwareMenuAction(action)
		}) })
		hardwareMenuButton.menu = UIMenu(children: hardwareOptions)

		// Set up the memory options menu.
		let memoryOptions: [UIAction] = [4, 8, 16, 24, 32, 64].map({ UIAction(title: String($0), handler: {[self] (action: UIAction) in
			self.memoryMenuAction(action)
		}) })
		memoryMenuButton.menu = UIMenu(children: memoryOptions)

		// Set up the zone popup menu.
		let zones = design?.zones ?? []
		let zoneOptions: [UIAction] = zones.map({ UIAction(title: $0.name, handler: {[self] (action: UIAction) in
			self.zoneMenuAction(action)
		}) })
		zoneMenuButton.menu = UIMenu(children: zoneOptions)

		// Set up the Compute Node Type popup menu.
		let typeOptions: [UIAction] = ComputeNodeType.allCases.map({$0.stringValue}).map({ UIAction(title: $0, handler: {[self] (action: UIAction) in
			self.typeMenuAction(action)
		}) })
		typeMenuButton.menu = UIMenu(children: typeOptions)
		
		updateUI()
    }
    
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Virtual Machines"
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VMCell", for: indexPath)
		return cell
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
