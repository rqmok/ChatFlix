//
//  ThemeTitleLabel.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 3/6/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class ThemeTitleLabel: UILabel {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textColor = Colors.accent
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
