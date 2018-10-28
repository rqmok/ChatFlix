//
//  AddFriendViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 18/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

protocol AddFriendProtocol {
    func addFriend(friend: Friend)
}

class AddFriendViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    
    var addFriendDelegate: AddFriendProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addFriend(_ sender: Any) {
        guard let email = emailTextField.text else {
            self.displayErrorMessage("Please enter an email address")
            return
        }
        
        Constants.refs.databaseUsers.queryOrdered(byChild: "email/emailAddress").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? NSDictionary else {
                self.displayErrorMessage("Could not find user with email \(email)")
                return
            }
            
            guard let currentID = Auth.auth().currentUser?.uid else {
                self.displayErrorMessage("Please login to continue")
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            for (id,_) in value {
                guard currentID != "\(id)" else {
                    self.displayErrorMessage("Cannot add yourself as a friend")
                    return
                }
                
                // Get the data under the user's id as a dictionary
                guard let userData = value.value(forKey: "\(id)") as? NSDictionary else {
                    return
                }
                
                // Construct the full name of the user from the userData dictionary
                var fullName: String = ""
                for (_, name) in userData.value(forKey: "names") as! NSDictionary {
                    fullName.append(" \(name)")
                }
                fullName.removeFirst()
                
                // Construct an email dictionary from data in userData
                guard let emailDict = userData.value(forKey: "email") as? NSDictionary else {
                    return
                }
                
                // Get the email of the user from userData dictionary
                let email = emailDict.value(forKey: "emailAddress") as! String
                
                // Add the friend's name and email address in firebase
                Constants.refs.databaseUsers.child(currentID).child("friends").child("\(id)").updateChildValues(["fullName": fullName])
                Constants.refs.databaseUsers.child(currentID).child("friends").child("\(id)").updateChildValues(["emailAddress": email])
                
                // Create a new friend object
                let friend = Friend(friendID: "\(id)", fullName: fullName, email: email)
                // Update the previous view controller
                self.addFriendDelegate?.addFriend(friend: friend)
            }
            
            self.dismiss(animated: true, completion: nil)
            
        }) { (error) in
            self.displayErrorMessage(error.localizedDescription)
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
