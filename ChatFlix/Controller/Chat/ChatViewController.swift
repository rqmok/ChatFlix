//
//  ChatViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 21/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    // Stores all groups the current logged in user is involved in
    private var groups: [Group] = []
    
    // Stores the filtered groups for searching
    private var filteredGroups: [Group] = []
    
    // Handle for listening for newly added groups
    private var groupsRefHandle: DatabaseHandle?
    
    // The reference for group ids for this current user
    private var groupsRef: DatabaseReference? {
        if let userID = Auth.auth().currentUser?.uid {
            return Constants.refs.databaseUsers.child(userID).child("groups")
        } else {
            return nil
        }
    }
    
    // The group which will be sent when a group is clicked on
    var groupToSend: Group?
    
    // Listener for auth state
    var authListener: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise variables
        groupToSend = nil
        
        // Prepare nib file for group table cell
        let nib = UINib(nibName: "GroupTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "groupCell")
        
        // Add a search controller for searching groups
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Groups"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    deinit {
        self.detachDatabaseHandler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        if Auth.auth().currentUser != nil {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.resetGroupsData()
        } else {
            // Reset the data
            self.groups = []
            self.filteredGroups = []
            self.tableView.reloadData()
            
            // Detach the database handler
            self.detachDatabaseHandler()
            
            self.tableView.delegate = nil
            self.tableView.dataSource = nil
            
            self.showLoginViewController()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.detachDatabaseHandler()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper function to reset the groups list
    private func resetGroupsData() {
        // Detach the handler
        self.detachDatabaseHandler()
        // Reset the list
        self.groups = []
        self.filteredGroups = []
        self.tableView.reloadData()
        // Load groups
        self.loadGroups()
    }
    
    private func detachDatabaseHandler() {
        if let refHandle = groupsRefHandle, let ref = groupsRef {
            ref.removeObserver(withHandle: refHandle)
        }
    }
    
    private func loadGroups() {
        guard let ref = groupsRef else {
            return
        }
        
        let query = ref.queryOrderedByKey()
        
        groupsRefHandle = query.observe(.childAdded, with: { groupIDsSnapshot in
            // Decode the snapshot
            let groupID = groupIDsSnapshot.key
            
            // Get information about this group from firebase
            Constants.refs.databaseGroups.child(groupID).observeSingleEvent(of: .value, with: { groupSnapshot in
                // Decode the information
                guard let groupData = groupSnapshot.value as? NSDictionary else {
                    print("Could not retrieve data for group with id \(groupID)")
                    return
                }
                
                // Get the group name
                guard let groupName = groupData.value(forKey: "groupName") as? String else {
                    print("Could not retrieve name of group with id \(groupID)")
                    return
                }
                
                // Get the last message
                guard let lastMessage = groupData.value(forKey: "lastMessage") as? String else {
                    print("Could not retrieve last message of group with id \(groupID)")
                    return
                }
                
                // Get the timestamp
                guard let timestamp = groupData.value(forKey: "timestamp") as? TimeInterval else {
                    print("Could not retrieve timestamp of group with id \(groupID)")
                    return
                }
                
                // Construct a group object
                let group = Group(groupName: groupName, groupID: groupID, lastMessage: lastMessage, timestamp: timestamp)
                
                // Get the members for the group
                guard let members = groupData.value(forKey: "membersIDs") as? NSDictionary else {
                    print("Could not retrieve members of group with id \(groupID)")
                    return
                }
                
                // Go through each member
                for memberIDKey in members.allKeys {
                    // Convert the memberID to string
                    guard let memberID = memberIDKey as? String else {
                        return
                    }
                    
                    // Add the member to the group
                    group.membersIDs.append(memberID)
                }
                
                // Add the group to the list of objects
                self.groups.insert(group, at: 0)
                self.filteredGroups.insert(group, at: 0)
                
                // Add a table row for this new group
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            })
        })
    }
    
    private func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(controller, animated: true, completion: {
            self.tabBarController?.selectedIndex = 0
        })
    }
    
    private func displayErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupChatSegue" {
            let destinationVC = segue.destination as! GroupChatViewController
            destinationVC.group = groupToSend
            destinationVC.removeGroupDelegate = self
            destinationVC.addFriendsToGroupDelegate = self
        }
    }

}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell
        
        // Change labels of the cell from groups list
        cell.groupNameLabel.text = self.filteredGroups[indexPath.row].groupName
        cell.lastMessageLabel.text = self.filteredGroups[indexPath.row].lastMessage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Change timestamp of selected row and re-order table rows
        
        // Set the group that needs to be sent
        self.groupToSend = filteredGroups[indexPath.row]
        
        // Check if names are available
        if Constants.currentUser.firstName != nil, Constants.currentUser.lastName != nil {
            // Names are available
            self.performSegue(withIdentifier: "groupChatSegue", sender: nil)
        } else {
            // Names are not available. Download them.
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            Constants.refs.databaseUsers.child(userID).child("names").observeSingleEvent(of: .value, with: { snapshot in
                // Decode the snapshot
                guard let names = snapshot.value as? NSDictionary else {
                    return
                }
                
                // Get the first name
                guard let firstName = names.value(forKey: "firstname") as? String else {
                    return
                }
                
                // Get the last name
                guard let lastName = names.value(forKey: "lastname") as? String else {
                    return
                }
                
                // Store the names
                Constants.currentUser.firstName = firstName
                Constants.currentUser.lastName = lastName
                
                // Now perform the segue
                self.performSegue(withIdentifier: "groupChatSegue", sender: nil)
            })
        }
    }
}

extension ChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            self.filteredGroups = self.groups.filter({ (group: Group) -> Bool in
                return group.groupName.lowercased().contains(searchText.lowercased()) ||
                    group.lastMessage.lowercased().contains(searchText.lowercased())
            })
        } else {
            self.filteredGroups = groups
        }
        
        self.tableView.reloadData()
    }
}

extension ChatViewController: removeGroupProtocol {
    func removeGroup(group: Group) {
        // Use helper function to remove from firebase
        self.leaveGroup(group: group)
    }
    
    // Helper function that allows a user to leave the group
    private func leaveGroup(group: Group) {
        if let userID = Auth.auth().currentUser?.uid {
            // Detach the observer to prevent errors
            self.detachDatabaseHandler()
            
            // Remove group from user id in firebase
            Constants.refs.databaseUsers.child(userID).child("groups").child(group.groupID).removeValue(completionBlock: { (error, ref) in
                // Display error, if any
                if error != nil {
                    self.displayErrorMessage(error!.localizedDescription)
                    return
                }
                
                // Reference to the group in the database
                let groupRef = Constants.refs.databaseGroups.child(group.groupID)
                
                // Remove current user from group
                groupRef.child("membersIDs").child(userID).removeValue(completionBlock: { (error, ref) in
                    // Display error, if any
                    if error != nil {
                        self.displayErrorMessage(error!.localizedDescription)
                        return
                    }
                    
                    // Check if this was the last member in the group
                    groupRef.observeSingleEvent(of: .value, with: { groupSnapshot in
                        // Reload the groups data
                        self.resetGroupsData()
                        
                        if groupSnapshot.hasChild("membersIDs") {
                            // Group still has members
                            return
                        } else {
                            // Group does not have any more members
                            // Remove the group's messages from firebase
                            groupRef.removeValue()
                            // Remove messages for this group as well
                            Constants.refs.databaseMessages.child(group.groupID).removeValue()
                        }
                    })
                })
            })
        }
    }
}

extension ChatViewController: addFriendsToGroupProtocol {
    func addFriendsToGroup(group: Group, friends: [Friend]) {
        // Detach listener to prevent errors
        self.detachDatabaseHandler()
        // Go through each friend
        for friend in friends {
            // Add the friend to the group in firebase
            Constants.refs.databaseUsers.child(friend.friendID).child("groups").updateChildValues([group.groupID: true])
            Constants.refs.databaseGroups.child(group.groupID).child("membersIDs").updateChildValues([friend.friendID: true])
            
            // Add the friend to the group object
            group.membersIDs.append(friend.friendID)
        }
        // Reload the groups data
        self.resetGroupsData()
    }
}
