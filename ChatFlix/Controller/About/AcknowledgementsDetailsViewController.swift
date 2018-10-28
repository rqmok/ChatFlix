//
//  AcknowledgementsDetailsViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 3/6/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import WebKit

class AcknowledgementsDetailsViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var titleToShow: String?
    var urlToLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showProgress(show: false)
        
        self.webView.navigationDelegate = self
        
        // Load the title
        if let title = titleToShow {
            self.navigationItem.title = title
        }

        // Load the url
        if let url = urlToLoad {
            self.webView.scrollView.isScrollEnabled = true
            self.webView.load(URLRequest(url: url))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showProgress(show: Bool) {
        if show {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        } else {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
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

extension AcknowledgementsDetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgress(show: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showProgress(show: false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showProgress(show: false)
    }
}
