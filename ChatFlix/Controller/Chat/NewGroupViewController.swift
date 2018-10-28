//
//  NewGroupViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 30/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class NewGroupViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var groupNameTextField: UITextField!
    
    // Contains all friends of the current user
    var friends: [Friend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the table view delegate and datasource
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Load the nib file for friend table view cell
        let nib = UINib(nibName: "FriendTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "friendCell")
        
        // Load friends using helper function
        self.loadFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createGroup(_ sender: Any) {
        // Check if group name was entered
        guard let groupName = self.groupNameTextField.text, groupName.count > 0 else {
            self.displayErrorMessage("Please enter a group name")
            return
        }
        
        // Check if any cells were selected
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            self.displayErrorMessage("Please select at least one friend for the group")
            return
        }
        
        // Create a new progress alert
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        // Start the alert on a new thread
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
        
        // Last message and timestamp need to be uploaded to Firebase
        // Keep them prepared
        let lastMessage = "Select to start sending messages"
        let timestamp = NSDate().timeIntervalSince1970
        
        // Create a new auto id for the new group
        let groupID = Constants.refs.databaseGroups.childByAutoId()
        
        // Create a members dictionary that will be uploaded
        var members: [String:Any] = [:]
        
        // Go through each selected index path
        for indexPath in selectedIndexPaths {
            let friendID = self.friends[indexPath.row].friendID
            members[friendID] = true
        }
        
        // Add current user id to members as well
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        members[userID] = true
        
        // Create a dictionary for the group to be uploaded
        let groupData: [String:Any] = [
            "groupName": groupName,
            "lastMessage": lastMessage,
            "timestamp": timestamp,
            "membersIDs": members
        ]
        
        // Upload group data to firebase
        groupID.updateChildValues(groupData)
        
        // Upload this group ID to each user's profile
        for groupUserID in members.keys {
            Constants.refs.databaseUsers.child(groupUserID).child("groups").updateChildValues([groupID.key: true])
        }
        
        // Close the progress alert
        DispatchQueue.main.async {
            alertController.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    private func loadFriends() {
        // Get the id of the current user
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        Constants.refs.databaseUsers.child(userID).child("friends").observeSingleEvent(of: .value, with: { friendsSnapshot in
            // Decode the snapshot
            guard let friendsData = friendsSnapshot.value as? NSDictionary else {
                self.displayErrorMessage("It seems you don't have any friends yet. Please add friends before continuing")
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            // Go through each friend
            for (id, _) in friendsData {
                // Get friend data for this id
                guard let friendData = friendsData.value(forKey: "\(id)") as? NSDictionary else {
                    print("Could not decode data for friend with id \(id)")
                    return
                }
                
                // Get friend name
                guard let fullName = friendData.value(forKey: "fullName") as? String else {
                    return
                }
                
                // Get friend email
                guard let friendEmail = friendData.value(forKey: "emailAddress") as? String else {
                    return
                }
                
                // Create and add a new Friend object to the list
                self.friends.append(Friend(friendID: "\(id)", fullName: fullName, email: friendEmail))
                
                // Add the friend table row
                self.tableView.insertRows(at: [IndexPath(row: self.friends.count - 1, section: 0)], with: .none)
            }
        })
    }
    
    private func displayErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
        
        cell.nameLabel.text = self.friends[indexPath.row].fullName
        cell.emailLabel.text = self.friends[indexPath.row].email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
