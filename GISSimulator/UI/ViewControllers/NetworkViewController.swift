//
//  NetworkViewController.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-25.
//

import UIKit


class NetworkViewController: UITableViewController,
							 UIAdaptivePresentationControllerDelegate {

	private var document: Document? {
		VCUtil.getDocument(self)
	}
	
	private var design: Design? {
		VCUtil.getDesign(self)
	}
	
	static func image(for zone: Zone) -> UIImage? {
		switch zone.zoneType {
		case .Secured:
			return  UIImage(named: "Network")
		case .Edge:
			return  UIImage(named: "LoadBalancer")
		case .Internet where zone.name == "AGOL":
			return  UIImage(named: "AGOL")
		case .Internet:
			return UIImage(named: "CloudMono")
		}
	}
	
	static func image(for conn:Connection) -> UIImage? {
		if conn.isLocal {
			return UIImage(systemName: "point.3.filled.connected.trianglepath.dotted")
		}
		else {
			return UIImage(systemName: "app.connected.to.app.below.fill")
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		//self.tableView.rowHeight = UITableView.automaticDimension
		//self.tableView.estimatedRowHeight = 85
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Section 0 is Zones, Section 1 is Connections
        return 2
    }

	private var zoneCount: Int {
		document?.data.design.zones.count ?? 0
	}
	
	private var connectionCount: Int {
		document?.data.design.network.count ?? 0
	}
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return zoneCount
		default:
			return connectionCount
		}
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		super.tableView(tableView, cellForRowAt: indexPath)
		let identifier: String
		switch indexPath.section {
		case 0:
			identifier = "ZoneTableCell"
		default:
			identifier = "ConnectionTableCell"
		}
		
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
		
		if let zoneCell = cell as? ZoneTableViewCell,
		   let zone = design?.zones[indexPath.row]
		{
			zoneCell.iconImage.image = NetworkViewController.image(for: zone)
			zoneCell.nameLabel.text = "\(zone.name) - \(zone.description)"
			if let local = zone.localConnection(in: design?.network ?? []) {
				zoneCell.bandwidthLabel.text = "Bandwidth: \(local.bandwidthMbps) Mbps"
			}
			let conns = zone.connections(in: design?.network ?? [])
			zoneCell.connectionsLabel.text = "Has \(conns.count) network connection(s)"
		}
		else if let connCell = cell as? ConnectionTableViewCell,
			let conn = design?.network[indexPath.row] {
			connCell.iconImage.image = NetworkViewController.image(for: conn)
			connCell.nameLabel.text = conn.name
			connCell.bandwidthLabel.text = "Bandwidth: \(conn.bandwidthMbps) Mbps"
			connCell.latencyLabel.text = "Latency: \(conn.latencyMs) ms"
		}

		cell.layoutIfNeeded()
        return cell
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Zones"
		default:
			return "Connections"
		}
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let button: UIButton
		if section == 0 {
			let action = UIAction(title: "Add Zone", image: UIImage(systemName: "plus.app")) { _ in
				print("Add zone!")
			}
			button = UIButton(primaryAction: action)
		}
		else {
			let action = UIAction(title: "Add Connection", image: UIImage(systemName: "plus.app.fill")) { _ in
				print("Add connection!")
			}
			button = UIButton(primaryAction: action)
		}
		return button
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 60
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0,
			let design = design {
			let zone = design.zones[indexPath.row]

			for i in 0..<design.zones.count {
				if indexPath.row != i {
					tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: false)
				}
			}
			
			// Highlight the connection rows corresponding to the selected zone
			// Clear any connections not related to zone
			for i in 0..<design.network.count {
				if design.network[i].source == zone || design.network[i].destination == zone {
					tableView.selectRow(at: IndexPath(row: i, section: 1), animated: true, scrollPosition: .none)
				}
				else {
					tableView.deselectRow(at: IndexPath(row: i, section: 1), animated: false)
				}
			}
		}
	}

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destination.
		if let zoneDetailVC = segue.destination as? ZoneDetailViewController,
			let cell = sender as? UITableViewCell,
			let design = design
		{
			// Pass the selected object to the new view controller.
			let zone = design.zones[tableView.indexPath(for: cell)!.row]
			zoneDetailVC.design = design
			zoneDetailVC.zone = zone
			segue.destination.presentationController?.delegate = self
		}
    }
 
	@IBAction func unwindToNetworkViewController(_ segue: UIStoryboardSegue) {
		if let zoneDetailVC = segue.source as? ZoneDetailViewController {
			handleZoneDetailDismissal(zoneDetailVC)
		}
	}
	
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		if let zoneDetailVC = presentationController.presentedViewController as? ZoneDetailViewController {
			handleZoneDetailDismissal(zoneDetailVC)
		}
	}
	
	private func handleZoneDetailDismissal(_ zoneDetailVC: ZoneDetailViewController) {
		let zone = zoneDetailVC.zone
		if zoneDetailVC.deletedZone,
			let design = design,
			let document = document {
			document.data.design.remove(zone: zone)
			document.undoManager?.registerUndo(withTarget: document) {
				$0.data.design = design
			}
		}
		if let design = design,
		   let local = zoneDetailVC.localConnection,
		   let document = document {
			document.data.design.replace(connection: local)
			document.data.design.replace(zone: zone)
			document.undoManager?.registerUndo(withTarget: document) {
				$0.data.design = design
			}
		}
		
		tableView.reloadData()
	}

}
