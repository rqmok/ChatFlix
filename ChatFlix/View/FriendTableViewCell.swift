//
//  AddGroupFriendTableViewCell.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 1/6/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: ThemePrimaryLabel!
    @IBOutlet weak var emailLabel: ThemeSecondaryLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
