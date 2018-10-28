//
//  MovieCollectionViewCell.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 11/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var movieImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Theme the cell
        // Credit: https://gist.github.com/nor0x/076cef18b1e412d2f432da911b9a5bab
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true;
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width:0,height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false;
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
}
