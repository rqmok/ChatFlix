//
//  ThemeLabel.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 27/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class ThemePrimaryLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Theme the label
        self.textColor = Colors.primaryText
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
