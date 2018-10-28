//
//  TicketsTableViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 20/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

private class MovieTicket {
    var ticketID: String
    var movieID: Int
    var movieTitle: String
    var movieImagePath: String
    var date: String
    var time: String
    
    init(ticketID: String, movieID: Int, movieTitle: String, movieImagePath: String, date: String, time: String) {
        self.ticketID = ticketID
        self.movieID = movieID
        self.movieTitle = movieTitle
        self.movieImagePath = movieImagePath
        self.date = date
        self.time = time
    }
}

class TicketsTableViewController: UITableViewController {
    
    // Stores the user's tickets
    private var movieTickets: [MovieTicket] = []
    
    // Stores the filtered tickets for search updating
    private var filteredTickets: [MovieTicket] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        filteredTickets = movieTickets
        
        // Create a search controller for enabling searching
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Tickets"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        
        // Load all the tickets into a list using helper function
        loadTickets()
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
    
    private func loadTickets() {
        // Get the user id
        guard let userID = Auth.auth().currentUser?.uid else {
            self.displayErrorMessage("Please log in before continuing")
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        Constants.refs.databaseUsers.child(userID).child("tickets").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? NSDictionary else {
                return
            }
            
            for (id, _) in value {
                // Get the dictionary under this id
                guard let ticket = value.value(forKey: "\(id)") as? NSDictionary else {
                    return
                }
                
                // Retrieve necessary values from ticket
                guard let ticketID = id as? String else {
                    print("Unable to retrieve ticket id")
                    return
                }
                guard let movieID = ticket.value(forKey: "movieID") as? Int else {
                    print("Unable to retrieve movie id")
                    return
                }
                guard let date = ticket.value(forKey: "date") as? String else {
                    print("Unable to retrieve ticket date")
                    return
                }
                guard let time = ticket.value(forKey: "time") as? String else {
                    print("Unable to retrieve ticket time")
                    return
                }
                
                // Ask the API to get details about the movie
                API.getMovie(id: movieID, completion: { movie in
                    // Get the movie title
                    guard let movieTitle = movie?.title else {
                        print("Movie title not retrieved")
                        return
                    }
                    // Get the movie image path
                    guard let imagePath = movie?.posterPath else {
                        print("Movie image path not retrieved")
                        return
                    }
                    
                    // Store the ticket in the data list
                    self.movieTickets.append(MovieTicket(ticketID: ticketID, movieID: movieID, movieTitle: movieTitle, movieImagePath: imagePath, date: date, time: time))
                    self.filteredTickets.append(MovieTicket(ticketID: ticketID, movieID: movieID, movieTitle: movieTitle, movieImagePath: imagePath, date: date, time: time))
                    
                    // Add the table row
                    self.tableView.insertRows(at: [IndexPath(row: self.filteredTickets.count - 1, section: 0)], with: .automatic)
                })
            }
        })
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
        return filteredTickets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell", for: indexPath) as! TicketTableViewCell
        
        // Start the activity indicator to show user that data is loading
        cell.progressIndicator.startAnimating()
        cell.progressIndicator.isHidden = false

        // Get the current movie ticket
        let movieTicket = filteredTickets[indexPath.row]
        
        // Use KingFisher to download image
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(movieTicket.movieImagePath)")
        let resource = ImageResource(downloadURL: url!, cacheKey: String(movieTicket.movieID))
        
        // Change cell label texts
        cell.movieTitle.text = movieTicket.movieTitle
        cell.movieDate.text = movieTicket.date
        cell.movieTime.text = movieTicket.time
        
        // Set the cell image
        cell.movieImage.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            // Stop the progress indicator
            cell.progressIndicator.isHidden = true
            cell.progressIndicator.stopAnimating()
        })

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the id of the ticket to be deleted
            let ticketID = filteredTickets[indexPath.row].ticketID
            // Get the id of current user
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            // Remove the ticket from firebase
            Constants.refs.databaseUsers.child(userID).child("tickets").child(ticketID).removeValue(completionBlock: { error, ref in
                if error != nil {
                    self.displayErrorMessage(error!.localizedDescription)
                } else {
                    // Remove the ticket from local lists
                    self.filteredTickets.remove(at: indexPath.row)
                    // Find and delete from original list as well
                    for i in 0..<self.movieTickets.count {
                        if self.movieTickets[i].ticketID == ticketID {
                            self.movieTickets.remove(at: i)
                            break
                        }
                    }
                    // Delete the table row
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TicketsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Filter the original list
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredTickets = movieTickets.filter({ (movieTicket: MovieTicket) -> Bool in
                // Compare the title to the search query
                return movieTicket.movieTitle.lowercased().contains(searchText.lowercased())
            })
        } else {
            filteredTickets = movieTickets
        }
        
        // reload the table data
        self.tableView.reloadData()
    }
}
