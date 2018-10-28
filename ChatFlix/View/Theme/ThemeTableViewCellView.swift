//
//  TableViewCellView.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 27/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class ThemeTableViewCellView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Theme the view
        self.layer.cornerRadius = 8
        self.layer.backgroundColor = Colors.listCardBackground.cgColor
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
