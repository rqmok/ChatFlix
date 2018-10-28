//
//  SelectGroupShareViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 2/6/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class SelectGroupShareViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // Stores the groups to which the movie can be shared to
    var groups: [Group] = []
    
    // Stores the id of the movie which needs to be shared
    var idToShare: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load nib file for table view cell
        let nib = UINib(nibName: "GroupTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "groupCell")
        
        // Set table view delegate and datasource
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Load the groups
        self.loadGroups()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func loadGroups() {
        // Get current user id
        guard let userID = Auth.auth().currentUser?.uid else {
            self.displayErrorMessage("Please login to continue")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        Constants.refs.databaseUsers.child(userID).child("groups").observeSingleEvent(of: .value, with: { groupsSnapshot in
            // Decode the snapshot
            guard let groupsIDS = groupsSnapshot.value as? NSDictionary else {
                print("Could not retrieve group ids for current user.")
                return
            }
            
            // Go through each group id
            for (id, _) in groupsIDS {
                if let groupID = id as? String {
                    // Get information about this group from firebase
                    Constants.refs.databaseGroups.child(groupID).observeSingleEvent(of: .value, with: { groupSnapshot in
                        // Decode the snapshot
                        guard let groupData = groupSnapshot.value as? NSDictionary else {
                            print("Could not retrieve group data for group with id \(groupID)")
                            return
                        }
                        
                        // Get data for each group
                        if let groupName = groupData.value(forKey: "groupName") as? String,
                            let lastMessage = groupData.value(forKey: "lastMessage") as? String,
                            let timestamp = groupData.value(forKey: "timestamp") as? TimeInterval {
                            // Create a new group object
                            let group = Group(groupName: groupName, groupID: groupID, lastMessage: lastMessage, timestamp: timestamp)
                            /*
                             There is no need to download members IDs for this group.
                             This is because that information is not needed here.
                             If needed in the future, they can be accessed through groupData.value(forKey: "membersIDs")
                             */
                            
                            // Add the group to the list of groups
                            self.groups.insert(group, at: 0)
                            
                            // Insert a new table row for this group
                            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        }
                    })
                }
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

extension SelectGroupShareViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell
        
        cell.groupNameLabel.text = self.groups[indexPath.row].groupName
        cell.lastMessageLabel.text = self.groups[indexPath.row].lastMessage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the current user id
        guard let userID = Constants.currentUser.id else {
            self.displayErrorMessage("There was a problem in trying to share this movie. Please try again at a later time.")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let groupID = self.groups[indexPath.row].groupID
        
        // Create a reference for the new message
        let messageRef = Constants.refs.databaseMessages.child(groupID).childByAutoId()
        
        // Prepare timestamp
        let timestamp = NSDate().timeIntervalSince1970
        // Prepare message
        let messageText = "\(Constants.messages.movieMessagePrefix)\(self.idToShare!)"
        
        // Get the user's full name
        Constants.refs.databaseUsers.child(userID).child("names").observeSingleEvent(of: .value, with: { snapshot in
            // Decode the snapshot
            if let names = snapshot.value as? NSDictionary,
                let firstName = names.value(forKey: "firstname") as? String,
                let lastName = names.value(forKey: "lastname") as? String {
                // Store the names in static variables so they can be used later
                Constants.currentUser.firstName = firstName
                Constants.currentUser.lastName = lastName
                
                // Construct a full name
                let fullName = "\(firstName) \(lastName)"
                
                // Construct a message to be uploaded
                let message: [String:Any] = [
                    "senderID": userID,
                    "senderName": fullName,
                    "timestamp": timestamp,
                    "message": messageText
                ]
                
                // Upload the message
                messageRef.setValue(message)
                messageRef.setValue(message, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        self.displayErrorMessage(error!.localizedDescription)
                    } else {
                        // Show an alert for a success message
                        let alert = UIAlertController(title: nil, message: "Movie has been shared!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
                            // Go back once user has clicked this action
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        })
    }
}
