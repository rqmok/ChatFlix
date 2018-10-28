//
//  Constants.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 11/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        
        static let databaseUsers = databaseRoot.child("users")
        
        static let databaseGroups = databaseRoot.child("groups")
        
        static let databaseMessages = databaseRoot.child("messages")
    }
    
    struct currentUser {
        static var id: String? {
            return Auth.auth().currentUser?.uid
        }
        static var firstName: String?
        static var lastName: String?
    }
    
    struct messages {
        static let movieMessagePrefix = "TheMovieDBMovieID://"
    }
    
    struct alerts {
        static let loadingAlert: () -> UIAlertController = {
            // Source: https://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            
            return alert
        }
    }
}
