//
//  MovieDetailsViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 12/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import WebKit
import Kingfisher
import Firebase

class MovieDetailsViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var webViewLoadIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDate: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    var movie: Movie?
    var movieImage: ImageResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Movie data
        self.loadMovieData()
        
        // Start activity indicator
        webViewLoadIndicator.startAnimating()
        webViewLoadIndicator.hidesWhenStopped = true
        
        // Set webview delegate
        webView.navigationDelegate = self
        
        // Load the youtube trailer video
        loadYoutube()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadMovieData() {
        if movie != nil && movieImage != nil {
            self.movieImageView.kf.setImage(with: movieImage!, placeholder: nil, options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
            self.movieTitle.text = self.movie!.title
            self.movieDate.text = self.movie!.releaseDate
            self.ratingLabel.text = "\(Int(self.movie!.rating * 10))%"
            self.movieOverview.text = self.movie!.overview
        }
    }
    
    func loadYoutube() {
        // Request for videos from api
        guard let movieID = movie?.id else {
            return
        }
        API.getVideos(id: movieID, completion: { results in
            self.webView.configuration.allowsInlineMediaPlayback = true // Disable forced full screen player
            self.webView.scrollView.isScrollEnabled = false // we don't need scroll for the player
            self.webView.contentMode = .scaleAspectFit
            
            let htmlStyle = "<style> iframe { margin: 0px !important; padding: 0px !important; border: 0px !important; } html, body { margin: 0px !important; padding: 0px !important; border: 0px !important; width: 100%; height: 100%; } </style>"
            
            self.webView.loadHTMLString("<html><head><style>\(htmlStyle)</style></head><body><iframe width='100%' height='100%' src='https://www.youtube.com/embed/\(results.first?.key ?? "")?&playsinline=1' frameborder='0' allowfullscreen></iframe></body></html>", baseURL: nil)
            
        })
    }
    
    @IBAction func showOptions(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        let bookAction = UIAlertAction(title: "Book Now", style: .default, handler: { action in
            if (Auth.auth().currentUser != nil) {
                self.performSegue(withIdentifier: "bookingSegue", sender: nil)
            } else {
                self.showLoginViewController()
            }
        })
        actionSheet.addAction(bookAction)
        
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: { action in
            if Auth.auth().currentUser != nil {
                if self.movie?.id != nil {
                    self.performSegue(withIdentifier: "shareMovieSegue", sender: nil)
                }
            } else {
                self.showLoginViewController()
            }
        })
        actionSheet.addAction(shareAction)
        
        self.present(actionSheet, animated: true)
    }
    
    private func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(controller, animated: true, completion: {
            self.tabBarController?.selectedIndex = 0
        })
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookingSegue" {
            let destinationVC = segue.destination as! TicketBookingViewController
            destinationVC.movieID = movie!.id
        } else if segue.identifier == "shareMovieSegue" {
            let destinationVC = segue.destination as! SelectGroupShareViewController
            destinationVC.idToShare = movie!.id
        }
    }

}

extension MovieDetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webViewLoadIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewLoadIndicator.stopAnimating()
    }
}
