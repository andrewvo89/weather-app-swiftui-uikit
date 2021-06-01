//
//  customTableViewCell.swift
//  weather-app-ios-swift
//
//  Created by Ethan Nguyen on 18/5/21.
//

import UIKit

class customTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
