//
//  AccountNameTableViewCell.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 16/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class AccountNameTableViewCell: UITableViewCell {
    @IBOutlet var accountNameTextField: UILabel!
    @IBOutlet var progressIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
