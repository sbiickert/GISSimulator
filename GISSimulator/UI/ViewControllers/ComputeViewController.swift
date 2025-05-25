//
//  ComputeViewController.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-25.
//

import UIKit

class ComputeViewController: UITableViewController {
	private var document: Document? {
		VCUtil.getDocument(self)
	}
	
	private var design: Design? {
		VCUtil.getDesign(self)
	}
	
	static func image(for node: ComputeNode) -> UIImage? {
		switch node.type {
		case .Client where node.hardwareDefinition.architecture != .Intel:
			return  UIImage(named: "Device")
		case .Client:
			return  UIImage(named: "Desktop")
		case .PhysicalServer:
			return  UIImage(named: "ServerHW")
		default:
			return UIImage(named: "ServerV")
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return design?.zones.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let zone = design?.zones[section] else {return 1}
		return max(zone.allComputeNodes(in: design!.computeNodes).count, 1)
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let zone = design?.zones[section] else {return nil}
		return "Zone \(zone.name): \(zone.description)"
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "NoComputeTableCell", for: indexPath)
		if let zone = design?.zones[indexPath.section]
		{
			let nodes = zone.allComputeNodes(in: design!.computeNodes)
			if indexPath.row >= nodes.count {
				var config = cell.defaultContentConfiguration()
				config.text = "No compute nodes"
				config.image = UIImage(systemName: "circle.slash")
				cell.contentConfiguration = config
			}
			else {
				cell = tableView.dequeueReusableCell(withIdentifier: "ComputeTableCell", for: indexPath)
				let nodeCell = cell as! ComputeTableViewCell
				let node = nodes[indexPath.row]
				nodeCell.iconImage.image = ComputeViewController.image(for: node)
				nodeCell.nameLabel.text = "\(node.name) - \(node.description)"
				nodeCell.specLabel.text = node.hardwareDefinition.processor
				var sizeText = ""
				if node.type == .Client || node.type == .PhysicalServer {
					sizeText += "\(node.hardwareDefinition.cores) cores, "
				}
				else {
					sizeText += "\(node.vCoreCount ?? 0) v. cores, "
				}
				sizeText += "\(node.memoryGB) GB"
				nodeCell.sizeLabel.text = sizeText
			}
		}

		cell.layoutIfNeeded()
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
