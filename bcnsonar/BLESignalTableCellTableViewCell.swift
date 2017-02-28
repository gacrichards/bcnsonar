//
//  BLESignalTableCellTableViewCell.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/13/16.
//  Copyright © 2016 Cole Richards. All rights reserved.
//

import UIKit

class BLESignalTableCellTableViewCell: UITableViewCell {
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var signalStrengthLabel: UILabel!
    @IBOutlet weak var toneLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
