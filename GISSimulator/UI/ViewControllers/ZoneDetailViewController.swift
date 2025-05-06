//
//  ZoneDetailViewController.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-29.
//

import UIKit

class ZoneDetailViewController: UIViewController,
								UITableViewDelegate,
								UITableViewDataSource,
								UITextFieldDelegate {
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBAction func nameChanged(_ sender: Any) {
		zone.name = nameTextField.text ?? zone.name
	}
	@IBOutlet weak var descriptionTextField: UITextField!
	@IBAction func descriptionChanged(_ sender: UITextField) {
		zone.description = descriptionTextField.text ?? zone.description
	}
	
	@IBOutlet weak var typeMenuButton: UIButton!
	@IBAction func typeMenuAction(_ sender: UIAction) {
		if let t = ZoneType(rawValue: sender.title) {
			zone.zoneType = t
		}
	}
	
	@IBOutlet weak var bandwidthTextField: UITextField!
	@IBOutlet weak var bandwidthMenuButton: UIButton!
	@IBAction func bandwidthMenuAction(_ sender: UIAction) {
		localConnection?.bandwidthMbps = Int(sender.title) ?? 1
		updateUI()
	}
	@IBAction func bandwidthChanged(_ sender: UITextField) {
		localConnection?.bandwidthMbps = Int(sender.text ?? "0") ?? 1
	}
	
	@IBOutlet weak var latencyTextField: UITextField!
	@IBAction func latencyChanged(_ sender: UITextField) {
		localConnection?.latencyMs = Int(sender.text ?? "0") ?? 0
	}
	
	@IBOutlet weak var tableview: UITableView!
	
	@IBOutlet weak var deleteButton: UIButton!
	@IBAction func deleteButtonClicked(_ sender: UIButton) {
		deletedZone = true
		performSegue(withIdentifier: "deleteZoneSegue", sender: self)
	}
	
	var design: Design? = nil
	
	var zone: Zone = Zone(name: "New Zone", description: "", zoneType: .Internet) {
		didSet {
			updateUI()
		}
	}
	
	var deletedZone: Bool = false
	
	private func updateUI() {
		guard design != nil, nameTextField != nil else { return }
		nameTextField.text = zone.name
		descriptionTextField.text = zone.description
		let local = localConnection
		bandwidthTextField.text = String(local?.bandwidthMbps ?? 0)
		latencyTextField.text = String(local?.latencyMs ?? 0)
		if let selectedItem = typeMenuButton.menu!.children.first(where: { $0.title == zone.zoneType.rawValue }) as? UIAction {
			selectedItem.state = .on
			print(selectedItem.title)
		}
		if let selectedItem = bandwidthMenuButton.menu!.children.first(where: { Int($0.title) == local?.bandwidthMbps ?? 0 }) as? UIAction {
			//selectedItem.state = .on
			//print(selectedItem.title)
		}
		tableview.reloadData()
	}
	
	private var _localConnection: Connection? = nil
	var localConnection: Connection? {
		get {
			guard let design = design else { return nil }
			if _localConnection == nil {
				_localConnection = zone.localConnection(in: design.network)
			}
			return _localConnection
		}
		set {
			_localConnection = newValue
		}
	}
	
	private var connections: [Connection] {
		guard let design = design else { return [] }
		return zone.connections(in: design.network)
			.sorted { $0.name < $1.name }
			.filter { $0.isLocal == false }
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return connections.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ZoneConnectionCell", for: indexPath)

		let conn = connections[indexPath.row]
		var config = cell.defaultContentConfiguration()
		config.text = conn.name
		config.secondaryText = conn.description
		config.image = NetworkViewController.image(for: conn)
		cell.contentConfiguration = config
		
		return cell
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == bandwidthTextField || textField == latencyTextField {
			let allowedCharacters = CharacterSet.decimalDigits
			let characterSet = CharacterSet(charactersIn: string)
			return allowedCharacters.isSuperset(of: characterSet)
		}
		return true
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the Zone Type popup menu.
		let options: [UIAction] = ZoneType.allCases.map({ UIAction(title: $0.rawValue, handler: {[self] (action: UIAction) in
			self.typeMenuAction(action)
		}) })
		typeMenuButton.menu = UIMenu(children: options)
		
		// Set up the bandwidth options menu.
		let bandwidthOptions: [UIAction] = [10, 100, 500, 1000, 2500, 10000].map({ UIAction(title: String($0), handler: {[self] (action: UIAction) in
			self.bandwidthMenuAction(action)
		}) })
		bandwidthMenuButton.menu = UIMenu(children: bandwidthOptions)
		
		updateUI()
		
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
