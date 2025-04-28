//
//  ConnectionTableViewCell.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-27.
//

import UIKit

class ConnectionTableViewCell: UITableViewCell {

	@IBOutlet weak var latencyLabel: UILabel!
	@IBOutlet weak var bandwidthLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var iconImage: UIImageView!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
