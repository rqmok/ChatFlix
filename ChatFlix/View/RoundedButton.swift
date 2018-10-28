//
//  RoundedButton.swift
//  Library of Alexandria
//
//  Created by Zeeshan Khan on 20/4/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//
// Allows a button's cornerRadius to be changed on demand

import UIKit

class RoundedButton: UIButton {
    
    private var cornerRadiusSize: CGFloat?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Change the background according to theme
        self.layer.backgroundColor = Colors.accent.cgColor
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            guard let radius = cornerRadiusSize else {
                return 0;
            }
            return radius
        }
        set {
            cornerRadiusSize = newValue
            layer.cornerRadius = cornerRadiusSize!
        }
    }
    
}
