//
//  RegisterViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 16/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
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
    
    @IBAction func registerAccount(_ sender: Any) {
        guard let firstName = firstNameTextField.text else {
            displayErrorMessage("Please enter your first name")
            return
        }
        
        guard let lastName = lastNameTextField.text else {
            displayErrorMessage("Please enter your last name")
            return
        }
        
        guard let emailAddress = emailTextField.text else {
            displayErrorMessage("Please enter your email address")
            return
        }
        
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter a password")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text else {
            displayErrorMessage("Please confirm your password")
            return
        }
        
        guard password == confirmPassword else {
            displayErrorMessage("Passwords are not the same")
            return
        }
        
        // Get the loading alert
        let loadingAlert = Constants.alerts.loadingAlert()
        // Display the loading alert
        DispatchQueue.main.async {
            self.present(loadingAlert, animated: true, completion: nil)
        }
        
        Auth.auth().createUser(withEmail: emailAddress, password: password) { (user, error) in
            // Dismiss the loading alert
            loadingAlert.dismiss(animated: true, completion: nil)
            
            if error != nil {
                self.displayErrorMessage(error!.localizedDescription)
            } else {
                // Create user in database and store names
                Constants.refs.databaseUsers.child(user!.uid).child("names").updateChildValues(["firstname": firstName])
                Constants.refs.databaseUsers.child(user!.uid).child("names").updateChildValues(["lastname": lastName])
                
                // Save the user's email address to the database
                Constants.refs.databaseUsers.child(user!.uid).child("email").updateChildValues(["emailAddress": emailAddress])
                
                // Then pop this view controller
                self.navigationController?.popViewController(animated: true)
            }
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
