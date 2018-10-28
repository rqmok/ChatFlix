//
//  TicketBookingViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 20/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase

class TicketBookingViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var timePicker: UIPickerView!
    
    private let timePickerData = ["9:30PM", "12:40PM", "3:20PM", "5:50PM", "8:45PM"]
    
    // Store the movie id to be uploaded to database
    var movieID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Limit the date picker start date to tomorrow
        datePicker.minimumDate = Date().tomorrow
        // Limit the data picker to one year
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        // Set time picker delegate and data source
        timePicker.delegate = self
        timePicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneSelectingBooking(_ sender: Any) {
        // Get the selected date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let bookingDate = dateFormatter.string(from: datePicker.date)
        
        // Get the selected time
        let bookingTime = timePickerData[timePicker.selectedRow(inComponent: 0)]
        
        // Confirm with the user that they want to book for selected time
        // Create a new Alert for this
        let alertController = UIAlertController(title: "Make Booking?", message: "Are you sure you want to make a booking for \(bookingTime) on \(bookingDate)?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
            // Get current user id
            guard let userID = Auth.auth().currentUser?.uid else {
                self.displayErrorMessage("You must log in before making a booking")
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            // Create data to upload to firebase
            let data: [String: Any] = [
                "movieID": self.movieID,
                "date": bookingDate,
                "time": bookingTime
            ]
            
            // Upload the ticket to firebase
            Constants.refs.databaseUsers.child(userID).child("tickets").childByAutoId().updateChildValues(data, withCompletionBlock: { (error, ref) in
                if let err = error {
                    self.displayErrorMessage(err.localizedDescription)
                } else {
                    // Display a success alert
                    let successAlert = UIAlertController(title: "Success!", message: "Your ticket has been booked!", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(successAlert, animated: true, completion: nil)
                }
            })
        })
        alertController.addAction(yesAction)
        
        // Add a No action as well
        alertController.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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

extension TicketBookingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows in each column
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timePickerData[row]
    }
}

// Source: https://stackoverflow.com/questions/44009804/swift-3-how-to-get-date-for-tomorrow-and-yesterday-take-care-special-case-ne
extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
