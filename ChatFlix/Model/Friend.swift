//
//  Friend.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 22/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import Foundation

class Friend {
    var friendID: String
    var fullName: String
    var email: String
    
    init(friendID: String, fullName: String, email: String) {
        self.friendID = friendID
        self.fullName = fullName
        self.email = email
    }
}
