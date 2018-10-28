//
//  AcknowledgementsTableViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 3/6/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class AcknowledgementsTableViewController: UITableViewController {
    
    private struct sections {
        static let NUM_SECTIONS = 3
        static let TheMovieDB = 0
        static let Cocoapods = 1
        static let Articles = 2
    }
    
    private let cocoapodsDataTitles: [String] = [
        "Cocoapods",
        "Alamofire",
        "Moya",
        "KingFisher",
        "Firebase",
        "JSQMessagesViewController"
    ]
    
    private let cocoapodsData: [String] = [
        "https://raw.githubusercontent.com/CocoaPods/CocoaPods/master/LICENSE",
        "https://raw.githubusercontent.com/Alamofire/Alamofire/master/LICENSE",
        "https://raw.githubusercontent.com/Moya/Moya/master/License.md",
        "https://raw.githubusercontent.com/onevcat/Kingfisher/master/LICENSE",
        "https://raw.githubusercontent.com/firebase/firebase-ios-sdk/master/LICENSE",
        "https://raw.githubusercontent.com/hemantasapkota/JSQMessagesViewController/master/LICENSE"
    ]
    
    private let theMovieDBDataTitles: [String] = [
        "The Movie Database (TMDb)"
    ]
    
    private let theMovieDBData: [String] = [
        "https://www.themoviedb.org/documentation/api/terms-of-use"
    ]
    
    private let articlesDataTitles: [String] = [
        "Movie App Swift 4",
        "How To: Build A Real-Time Chat App With Firebase And Swift",
        "Firebase Tutorial: Real-time Chat"
    ]
    
    private let articlesData: [String] = [
        "https://medium.com/@malcolmcollin/movie-app-swift-4-part-one-e6e03a993600",
        "https://learnappmaking.com/chat-app-ios-firebase-swift-xcode/",
        "https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2"
    ]
    
    private let headerHeight: CGFloat = 20
    
    // Stores the url that needs to be loaded to show the details
    private var urlToShow: URL?
    
    // Stores the title that the next view controller needs to have
    private var titleToShow: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func openAcknowledgementsDetails(title: String, url: URL) {
        self.titleToShow = title
        self.urlToShow = url
        self.performSegue(withIdentifier: "acknowledgementsDetailsSegue", sender: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.NUM_SECTIONS
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case sections.Cocoapods:
            return cocoapodsData.count
        case sections.TheMovieDB:
            return theMovieDBData.count
        case sections.Articles:
            return articlesData.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "acknowledgementCell", for: indexPath) as! AcknowledgementsTableViewCell
        
        var text: String = ""
        switch indexPath.section {
        case sections.Cocoapods:
            text = cocoapodsDataTitles[indexPath.row]
        case sections.TheMovieDB:
            text = theMovieDBDataTitles[indexPath.row]
        case sections.Articles:
            text = articlesDataTitles[indexPath.row]
        default:
            text = ""
        }
        
        cell.acknowledgementNameLabel.text = text

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var urlString: String?
        var titleString: String?
        switch indexPath.section {
        case sections.Cocoapods:
            titleString = cocoapodsDataTitles[indexPath.row]
            urlString = cocoapodsData[indexPath.row]
        case sections.TheMovieDB:
            titleString = theMovieDBDataTitles[indexPath.row]
            urlString = theMovieDBData[indexPath.row]
        case sections.Articles:
            titleString = articlesDataTitles[indexPath.row]
            urlString = articlesData[indexPath.row]
        default:
            titleString = nil
            urlString = nil
        }
        
        if let title = titleString, let urlStr = urlString, let url = URL(string: urlStr) {
            self.openAcknowledgementsDetails(title: title, url: url)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case sections.Cocoapods:
            return "CocoaPods"
        case sections.TheMovieDB:
            return "The Movie Database"
        case sections.Articles:
            return "Articles"
        default:
            return nil
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        // Change back item from "Acknowledgements" to simply "Back"
        // Source: https://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "acknowledgementsDetailsSegue" {
            let vc = segue.destination as! AcknowledgementsDetailsViewController
            vc.titleToShow = self.titleToShow
            vc.urlToLoad = self.urlToShow
        }
    }

}
