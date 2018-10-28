//
//  Group.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 30/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import Foundation

class Group {
    var groupName: String
    var groupID: String
    var lastMessage: String
    var timestamp: TimeInterval
    var membersIDs: [String]
    
    init(groupName: String, groupID: String, lastMessage: String, timestamp: TimeInterval) {
        self.groupName = groupName
        self.groupID = groupID
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.membersIDs = []
    }
}
