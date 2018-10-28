//
//  LocatorTableViewCell.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 11/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class LocatorTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Theme the labels
        titleLabel.textColor = Colors.primaryText
        subtitleLabel.textColor = Colors.secondaryText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
