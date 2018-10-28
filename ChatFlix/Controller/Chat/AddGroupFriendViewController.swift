//
//  AddGroupFriendViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 1/6/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

protocol addFriendsToGroupProtocol {
    func addFriendsToGroup(group: Group, friends: [Friend])
}

class AddGroupFriendViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    // Stores the friends that can be added to the group
    private var friends: [Friend] = []
    
    // Stores the group to which friends need to be added
    var group: Group?
    
    // Delegate to add friends for the given group
    var addFriendsToGroupDelegate: addFriendsToGroupProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the friend cell nib file
        let nib = UINib(nibName: "FriendTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "friendCell")
        
        // Assign self to table view as data source and delegate
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Call helper function to eligible friends
        self.loadFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addFriends(_ sender: Any) {
        guard let selectedRowsIndexPaths = tableView.indexPathsForSelectedRows else {
            displayErrorMessage("Please select at least one friend to add")
            return
        }
        
        // Compile a list of selected friends
        var selectedFriends: [Friend] = []
        for selectedIndexPath in selectedRowsIndexPaths {
            selectedFriends.append(self.friends[selectedIndexPath.row])
        }
        
        // Give the selected friends to the delegate to handle
        if let delegate = self.addFriendsToGroupDelegate {
            delegate.addFriendsToGroup(group: self.group!, friends: selectedFriends)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Helper function to check if a friend is already in the group
    private func friendInGroup(friendID: String) -> Bool {
        if let groupToCheck = self.group {
            for memberID in groupToCheck.membersIDs {
                if memberID == friendID {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func loadFriends() {
        // Get current user's id
        guard let userID = Auth.auth().currentUser?.uid else {
            self.displayErrorMessage("You need to be logged in to perform this action")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // Check that the group variable is present
        if self.group != nil {
            // Get the friends for this user
            Constants.refs.databaseUsers.child(userID).child("friends").observeSingleEvent(of: .value, with: { snapshot in
                // Decode the snapshot
                guard let friends = snapshot.value as? NSDictionary else {
                    print("Failed to retrieve friends for current user.")
                    return
                }
                
                // Go through each friend id
                for (id, _) in friends {
                    // Get the details of the friend
                    if let friendID = id as? String,
                        let friend = friends.value(forKey: friendID) as? NSDictionary,
                        let fullName = friend.value(forKey: "fullName") as? String,
                        let emailAddress = friend.value(forKey: "emailAddress") as? String {
                        
                        // Check if friend is already in the group
                        if (self.friendInGroup(friendID: friendID) == false) {
                            // Add the friend to the list
                            self.friends.append(Friend(friendID: friendID, fullName: fullName, email: emailAddress))
                            // Add a table row for this friend
                            self.tableView.insertRows(at: [IndexPath(row: self.friends.count - 1, section: 0)], with: .automatic)
                        }
                    }
                }
            })
        }
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

extension AddGroupFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        
        cell.nameLabel.text = self.friends[indexPath.row].fullName
        cell.emailLabel.text = self.friends[indexPath.row].email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
