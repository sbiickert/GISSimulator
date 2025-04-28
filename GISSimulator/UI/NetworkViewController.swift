//
//  NetworkViewController.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-25.
//

import UIKit


class NetworkViewController: UITableViewController {

	private var document: Document? {
		if let dvc = navigationController?.viewControllers.first(where: {$0 is DocumentViewController}) as? DocumentViewController {
			return dvc.designDoc
		}
		return nil
	}
	
	private var design: Design? {
		return document?.data.design
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
			switch zone.zoneType {
			case .Secured:
				zoneCell.iconImage.image = UIImage(named: "Network")
			case .Edge:
				zoneCell.iconImage.image = UIImage(named: "LoadBalancer")
			case .Internet where zone.name == "AGOL":
				zoneCell.iconImage.image = UIImage(named: "AGOL")
			case .Internet:
				zoneCell.iconImage.image = UIImage(named: "CloudMono")
			}
			
			zoneCell.nameLabel.text = "\(zone.name) - \(zone.description)"
			if let local = zone.localConnection(in: design?.network ?? []) {
				zoneCell.bandwidthLabel.text = "Bandwidth: \(local.bandwidthMbps) Mbps"
			}
			let conns = zone.connections(in: design?.network ?? [])
			zoneCell.connectionsLabel.text = "Has \(conns.count) network connection(s)"
		}
		else if let connCell = cell as? ConnectionTableViewCell,
			let conn = design?.network[indexPath.row] {
			if conn.isLocal {
				connCell.iconImage.image = UIImage(systemName: "point.3.filled.connected.trianglepath.dotted")
			}
			else {
				connCell.iconImage.image = UIImage(systemName: "app.connected.to.app.below.fill")
			}
			connCell.nameLabel.text = conn.name
			connCell.bandwidthLabel.text = "Bandwidth: \(conn.bandwidthMbps) Mbps"
			connCell.latencyLabel.text = "Latency: \(conn.latencyMs) ms"
		}

		cell.layoutIfNeeded()
        return cell
    }
//	
//	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) {
//			return 44
//		}
//		return 85
//	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Zones"
		default:
			return "Connections"
		}
	}
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
