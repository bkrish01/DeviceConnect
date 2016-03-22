//
//  MyDeviceTableViewCell.swift
//  Patient ePRO
//
//  Created by Krishnapillai, Bala on 2/9/16.
//  Copyright © 2016 AMGEN. All rights reserved.
//

import UIKit

class MyDeviceTableViewCell: UITableViewCell {
    
    // MARK: Properties

    @IBOutlet weak var CalDate: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var last_upd: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

