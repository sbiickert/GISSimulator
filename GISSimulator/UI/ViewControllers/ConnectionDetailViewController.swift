//
//  ConnectionDetailViewController.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-05-10.
//

import UIKit

class ConnectionDetailViewController: UIViewController, UITextFieldDelegate {

	var delegate: DetailViewControllerDelegate?
	
	var zone: Zone? 				{ didSet { updateUI() }}
	var otherZone: Zone? 			{ didSet { updateUI() }}
	var network: [Connection] = []
	
	private var exitConn: Connection? {
		guard let zone, let otherZone else { return nil }
		return zone.exitConnections(in: network).filter({$0.destination == otherZone}).first
	}
	
	private var entryConn: Connection? {
		guard let zone, let otherZone else { return nil }
		return zone.entryConnections(in: network).filter({$0.source == otherZone}).first
	}
	
	@IBOutlet weak var zoneNameLabel: UILabel!
	
	@IBOutlet weak var exitConnLabel: UILabel!
	@IBOutlet weak var exitSwitch: UISwitch!
	@IBAction func exitSwitchChanged(_ sender: UISwitch) {
		guard let zone, let otherZone else { updateUI(); return }
		if exitSwitch.isOn {
			network.append(zone.connect(to: otherZone, bandwidthMbps: 1000, latencyMs: 0))
		}
		else if let exitConn {
			network.removeAll(where: {$0 === exitConn})
		}
		updateUI()
	}
	@IBOutlet weak var exitBandwidthTextField: UITextField!
	@IBAction func exitBandwidthChanged(_ sender: UITextField) {
		guard var conn = exitConn else {return}
		conn.bandwidthMbps = Int(sender.text ?? "0") ?? 1
		network.removeAll(where: {$0 === conn})
		network.append(conn)
		//updateUI()
	}
	@IBOutlet weak var exitBandwidthMenuButton: UIButton!
	@IBAction func exitBandwidthMenuAction(_ sender: UIAction) {
		guard var conn = exitConn else {return}
		conn.bandwidthMbps = Int(sender.title) ?? 1
		network.removeAll(where: {$0 === conn})
		network.append(conn)
		updateUI()
	}
	@IBOutlet weak var exitLatencyTextField: UITextField!
	@IBAction func exitLatencyChanged(_ sender: UITextField) {
		guard var conn = exitConn else {return}
		conn.latencyMs = Int(sender.text ?? "0") ?? 1
		network.removeAll(where: {$0 === conn})
		network.append(conn)
		//updateUI()
	}
	
	
	@IBOutlet weak var entryConnLabel: UILabel!
	@IBOutlet weak var entrySwitch: UISwitch!
	@IBAction func entrySwitchChanged(_ sender: UISwitch) {
		guard let zone, let otherZone else { updateUI(); return }
		if entrySwitch.isOn {
			network.append(otherZone.connect(to: zone, bandwidthMbps: 1000, latencyMs: 0))
		}
		else if let entryConn {
			network.removeAll(where: {$0 === entryConn})
		}
		updateUI()
	}
	@IBOutlet weak var entryBandwidthTextField: UITextField!
	@IBAction func entryBandwidthChanged(_ sender: UITextField) {
		guard var conn = entryConn else {return}
		conn.bandwidthMbps = Int(sender.text ?? "0") ?? 1
		network.removeAll(where: {$0 === conn})
		network.append(conn)
		//updateUI()
	}
	@IBOutlet weak var entryBandwidthMenuButton: UIButton!
	@IBAction func entryBandwidthMenuAction(_ sender: UIAction) {
		guard var conn = entryConn else {return}
		conn.bandwidthMbps = Int(sender.title) ?? 1
		network.removeAll(where: {$0 === conn})
		network.append(conn)
		updateUI()
	}
	@IBOutlet weak var entryLatencyTextField: UITextField!
	@IBAction func entryLatencyChanged(_ sender: UITextField) {
		guard var conn = entryConn else {return}
		conn.latencyMs = Int(sender.text ?? "0") ?? 1
		network.removeAll(where: {$0 === conn})
		network.append(conn)
		//updateUI()
	}
	
	private func updateUI() {
		guard let zone = zone, let otherZone = otherZone, zoneNameLabel != nil else { return }
		zoneNameLabel.text = "\(zone.name) - \(zone.description)"
		exitConnLabel.text = "Exit connection to \(otherZone.name)"
		exitSwitch.isOn = exitConn != nil
		exitBandwidthTextField.isEnabled = exitSwitch.isOn
		exitLatencyTextField.isEnabled = exitSwitch.isOn
		exitBandwidthTextField.text = exitConn != nil ? String(exitConn!.bandwidthMbps) : ""
		exitLatencyTextField.text = exitConn != nil ? String(exitConn!.latencyMs) : ""
		
		entryConnLabel.text = "Entry connection from \(otherZone.name)"
		entrySwitch.isOn = entryConn != nil
		entryBandwidthTextField.isEnabled = entrySwitch.isOn
		entryLatencyTextField.isEnabled = entrySwitch.isOn
		entryBandwidthTextField.text = String(entryConn?.bandwidthMbps ?? 0)
		entryLatencyTextField.text = String(entryConn?.latencyMs ?? 0)
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == exitBandwidthTextField || textField == exitLatencyTextField ||
			textField == entryBandwidthTextField || textField == entryLatencyTextField {
			let allowedCharacters = CharacterSet.decimalDigits
			let characterSet = CharacterSet(charactersIn: string)
			return allowedCharacters.isSuperset(of: characterSet)
		}
		return true
	}
	
	@objc func done() {
		delegate?.detailViewControllerDidDismiss(self)
		navigationController?.popViewController(animated: true)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		// Create the Done button
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		navigationController?.navigationBar.isHidden = false
		
		// Set up the bandwidth options menus.
		let exitBandwidthOptions: [UIAction] = [10, 100, 500, 1000, 2500, 10000].map({ UIAction(title: String($0), handler: {[self] (action: UIAction) in
			self.exitBandwidthMenuAction(action)
		}) })
		exitBandwidthMenuButton.menu = UIMenu(children: exitBandwidthOptions)
		
		let entryBandwidthOptions: [UIAction] = [10, 100, 500, 1000, 2500, 10000].map({ UIAction(title: String($0), handler: {[self] (action: UIAction) in
			self.entryBandwidthMenuAction(action)
		}) })
		entryBandwidthMenuButton.menu = UIMenu(children: entryBandwidthOptions)
		
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
