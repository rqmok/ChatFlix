//
//  FriendsTableViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 17/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class FriendsTableViewController: UITableViewController {
    
    private var friends: [Friend] = []
    private var filteredFriends: [Friend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        filteredFriends = friends
        
        // Add a search controller for searching friends
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Friends"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        
        // Load the nib file for friend table view cell
        let nib = UINib(nibName: "FriendTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "friendCell")
        
        self.loadFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadFriends() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.displayErrorMessage("Please login to continue")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        // Get IDs of all friends
        Constants.refs.databaseUsers.child(userID).child("friends").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let friends = snapshot.value as? NSDictionary else {
                return
            }
            
            for (id, _) in friends {
                // Get the name and email for this id
                Constants.refs.databaseUsers.child(userID).child("friends").child("\(id)").observeSingleEvent(of: .value, with: { snapshot in
                    
                    guard let value = snapshot.value as? NSDictionary else {
                        return
                    }
                    
                    guard let fullName = value.value(forKey: "fullName") as? String else {
                        return
                    }
                    
                    guard let email = value.value(forKey: "emailAddress") as? String else {
                        return
                    }
                    
                    // Create a new friend with the information
                    self.friends.append(Friend(friendID: "\(id)", fullName: fullName, email: email))
                    // Add to the filtered list
                    self.filteredFriends.append(Friend(friendID: "\(id)", fullName: fullName, email: email))
                    
                    // Add row to table
                    self.tableView.insertRows(at: [IndexPath(row: self.filteredFriends.count - 1, section: 0)], with: .automatic)
                }) { (error) in
                    self.displayErrorMessage(error.localizedDescription)
                }
            }
            
        }) { (error) in
            self.displayErrorMessage(error.localizedDescription)
        }
    }
    
    private func displayErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredFriends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

        // Get the friend
        let friend = filteredFriends[indexPath.row]
        
        // Set the label texts for the cell
        cell.nameLabel.text = friend.fullName
        cell.emailLabel.text = friend.email

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let id = self.filteredFriends[indexPath.row].friendID
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            // Delete the friend from firebase
            Constants.refs.databaseUsers.child(userID).child("friends").child(id).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                } else {
                    print("\(id) was deleted successfully.")
                    
                    // Delete from local filtered list
                    self.filteredFriends.remove(at: indexPath.row)
                    
                    // Delete from the original list as well
                    for i in 0..<self.friends.count {
                        if self.friends[i].friendID == id {
                            self.friends.remove(at: i)
                            break
                        }
                    }
                    
                    // Remove table row
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFriendSegue" {
            let vc = segue.destination as! AddFriendViewController
            vc.addFriendDelegate = self
        }
    }
    

}

extension FriendsTableViewController: AddFriendProtocol {
    public func addFriend(friend: Friend) {
        self.filteredFriends.append(friend)
        self.friends.append(friend)
        self.tableView.insertRows(at: [IndexPath(row: self.filteredFriends.count - 1, section: 0)], with: .automatic)
    }
}

extension FriendsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredFriends = friends.filter({ (friend: Friend) -> Bool in
                return friend.fullName.lowercased().contains(searchText.lowercased()) || friend.email.lowercased().contains(searchText.lowercased())
            })
        } else {
            filteredFriends = friends
        }
        
        self.tableView.reloadData()
    }
}
