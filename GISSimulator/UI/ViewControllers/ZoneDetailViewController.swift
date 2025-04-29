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
	@IBOutlet weak var descriptionTextField: UITextField!
	
	@IBOutlet weak var typeMenuButton: UIButton!
	@IBAction func typeButtonClicked(_ sender: UIButton) {
	}
	@IBOutlet weak var bandwidthTextField: UITextField!
	@IBOutlet weak var bandwidthMenuButton: UIButton!
	@IBAction func bandwidthButtonClicked(_ sender: UIButton) {
	}
	@IBOutlet weak var latencyTextField: UITextField!
	@IBOutlet weak var latencyStepper: UIStepper!
	@IBAction func latencyStepperChanged(_ sender: UIStepper) {
	}
	
	@IBOutlet weak var tableview: UITableView!
	
	@IBOutlet weak var deleteButton: UIButton!
	@IBAction func deleteButtonClicked(_ sender: UIButton) {
	}
	
	var design: Design? = nil
	
	var zone: Zone = Zone(name: "New Zone", description: "", zoneType: .Internet) {
		didSet {
			updateUI()
		}
	}
	
	private func updateUI() {
		guard let design = design, nameTextField != nil else { return }
		nameTextField.text = zone.name
		descriptionTextField.text = zone.description
		let local = zone.localConnection(in: design.network)
		bandwidthTextField.text = String(local?.bandwidthMbps ?? 0)
		latencyTextField.text = String(local?.latencyMs ?? 0)
		tableview.reloadData()
	}
	
	private var connections: [Connection] {
		guard let design = design else { return [] }
		return zone.connections(in: design.network)
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
	

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
