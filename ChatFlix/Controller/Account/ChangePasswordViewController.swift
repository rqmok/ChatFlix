//
//  ChangePasswordViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 3/6/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add observers for keyboard show and hide to allow scrolling
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ----- BEGIN CODE FOR SCROLLING WHEN KEYBOARD IS OUT ----- //
    // Source: https://stackoverflow.com/questions/26689232/scrollview-and-keyboard-swift
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    // ----- END CODE FOR SCROLLING WHEN KEYBOARD IS OUT ----- //
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePassword(_ sender: Any) {
        // Check current password
        guard let currentPassword = currentPasswordTextField.text, currentPassword.count > 0 else {
            self.displayErrorMessage("Please enter your current password")
            return
        }
        
        // Check new password
        guard let newPassword = newPasswordTextField.text, newPassword.count > 0 else {
            self.displayErrorMessage("Please enter your new password")
            return
        }
        
        // Confirm new password
        guard let confirmNewPassword = confirmNewPasswordTextField.text, confirmNewPassword.count > 0 else {
            self.displayErrorMessage("Please confirm your new password")
            return
        }
        
        // Check new passwords are the same
        guard newPassword == confirmNewPassword else {
            self.displayErrorMessage("Your new passwords do not match!")
            return
        }
        
        // Check new password is not the same as current password
        guard newPassword != currentPassword else {
            self.displayErrorMessage("New password cannot be the same as current password")
            return
        }
        
        // Get current user
        guard let user = Auth.auth().currentUser else {
            self.displayErrorMessage("Please login to continue")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // Get the user's email address
        Constants.refs.databaseUsers.child(user.uid).child("email").observeSingleEvent(of: .value, with: { snapshot in
            // Decode and get email
            if let value = snapshot.value as? NSDictionary,
                let emailAddress = value.value(forKey: "emailAddress") as? String {
                // Create a credential with current email and password
                let credential = EmailAuthProvider.credential(withEmail: emailAddress, password: currentPassword)
                
                // Reauthenticate with this credential to check current password is correct
                user.reauthenticate(with: credential, completion: { (error) in
                    if error != nil {
                        self.displayErrorMessage(error!.localizedDescription)
                    } else {
                        // Change to a new password
                        user.updatePassword(to: newPassword, completion: { (error) in
                            if error != nil {
                                self.displayErrorMessage(error!.localizedDescription)
                            } else {
                                // Show new success alert
                                let alert = UIAlertController(title: nil, message: "Password Successfully Changed!", preferredStyle: .alert)
                                // Add dismiss action
                                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
                                    // Dismiss the current controller
                                    self.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                    }
                })
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
