//
//  ComputeTableViewCell.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-05-23.
//

import UIKit

class ComputeTableViewCell: UITableViewCell {

	@IBOutlet weak var iconImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var specLabel: UILabel!
	@IBOutlet weak var sizeLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
