//
//  LoginViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 16/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add observers for keyboard show and hide to allow scrolling
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let userID = Auth.auth().currentUser?.uid {
                // Download the user's first and last name
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
                    
                    // Store the names in static variables
                    Constants.currentUser.firstName = firstName
                    Constants.currentUser.lastName = lastName
                    
                    // Dismiss this window
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func closeLoginView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginAccount(_ sender: Any) {
        guard let emailAddress = emailTextField.text else {
            displayErrorMessage("Please enter an email address")
            return
        }
        
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter a password")
            return
        }
        
        // Remove password field for security
        passwordTextField.text?.removeAll()
        
        // Get the loading alert
        let loadingAlert = Constants.alerts.loadingAlert()
        // Show the loading alert
        DispatchQueue.main.async {
            self.present(loadingAlert, animated: true, completion: nil)
        }
        
        Auth.auth().signIn(withEmail: emailAddress, password: password) { (user, error) in
            // Remove the alert
            loadingAlert.dismiss(animated: true, completion: nil)
            
            if error != nil {
                self.displayErrorMessage(error!.localizedDescription)
                return
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
