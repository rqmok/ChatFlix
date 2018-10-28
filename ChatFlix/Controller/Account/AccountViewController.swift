//
//  AccountViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 16/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    // Sections for table view
    let sectionsCount = 4
    let SECTION_NAME = 0, SECTION_TICKETS_FRIENDS = 1, SECTION_CHANGE_PASSWORD = 2, SECTION_LOGOUT = 3
    
    // Cell names for table view
    let cellIdentifiers: [[String]] = [
        ["nameCell"],
        ["ticketsCell", "friendsCell"],
        ["changePasswordCell"],
        ["signoutCell"]
    ]
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser == nil {
            tableView.delegate = nil
            tableView.dataSource = nil
            
            showLoginViewController()
        } else {
            if (tableView.delegate == nil) {
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.reloadData()
            }
        }
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
    
    private func startProgressIndicator(indicator: UIActivityIndicatorView) {
        indicator.startAnimating()
        indicator.isHidden = false
    }
    
    private func stopProgressIndicator(indicator: UIActivityIndicatorView) {
        indicator.isHidden = true
        indicator.stopAnimating()
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

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_TICKETS_FRIENDS:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = self.view.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == SECTION_LOGOUT) {
            do {
                try Auth.auth().signOut()
                self.tableView.delegate = nil
                self.tableView.dataSource = nil
                self.tableView.reloadData()
                
                // Change the tab so login will be shown if it is tried to access again
                self.tabBarController?.selectedIndex = 0
                
                // Remove names from constants
                Constants.currentUser.firstName = nil
                Constants.currentUser.lastName = nil
                
                self.showLoginViewController()
            } catch {}
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = cellIdentifiers[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if indexPath.section == SECTION_NAME {
            let accountNameCell = cell as! AccountNameTableViewCell
            
            // Start animating the progress indicator
            self.startProgressIndicator(indicator: accountNameCell.progressIndicator)
            
            // Get the name from Firebase
            let userID = Auth.auth().currentUser!.uid
            
            // Check if names are already stored
            if let firstName = Constants.currentUser.firstName, let lastName = Constants.currentUser.lastName {
                accountNameCell.accountNameTextField.text = "\(firstName) \(lastName)"
                
                // Stop animating the progress
                self.stopProgressIndicator(indicator: accountNameCell.progressIndicator)
            } else {
                Constants.refs.databaseUsers.child(userID).child("names").observeSingleEvent(of: .value, with: { snapshot in
                    
                    // Store as dictionary
                    guard let value = snapshot.value as? NSDictionary else {
                        return
                    }
                    
                    // Get first name
                    guard let firstName = value.value(forKey: "firstname") as? String else {
                        return
                    }
                    
                    // Get last name
                    guard let lastName = value.value(forKey: "lastname") as? String else {
                        return
                    }
                    
                    // Store the names as well
                    Constants.currentUser.firstName = firstName
                    Constants.currentUser.lastName = lastName
                    
                    // Set the text of the text field in the cell
                    accountNameCell.accountNameTextField.text = "\(firstName) \(lastName)"
                    
                    // Stop animating the progress
                    self.stopProgressIndicator(indicator: accountNameCell.progressIndicator)
                }) { (error) in
                    
                    accountNameCell.accountNameTextField.text = "Failed to fetch name"
                    
                    self.displayErrorMessage(error.localizedDescription)
                    
                    // Stop animating the progress
                    self.stopProgressIndicator(indicator: accountNameCell.progressIndicator)
                }
            }
        }
        
        return cell
    }
}












