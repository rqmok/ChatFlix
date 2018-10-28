//
//  TicketTableViewCell.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 20/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class TicketTableViewCell: UITableViewCell {
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieDate: UILabel!
    @IBOutlet var movieTime: UILabel!
    @IBOutlet var progressIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Theme the labels
        movieTitle.textColor = Colors.primaryText
        movieDate.textColor = Colors.secondaryText
        movieTime.textColor = Colors.secondaryText
        
        // Theme the image
        movieImage.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
