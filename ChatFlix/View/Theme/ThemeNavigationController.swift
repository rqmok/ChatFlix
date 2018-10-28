//
//  ThemeNavigationController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 27/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class ThemeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barStyle = .black

        // Theme the navigation bar
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Colors.primary
        
        // Theme the tab bar
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = Colors.primary
        self.tabBarController?.tabBar.tintColor = Colors.accent
        
        // Theme the title text in navigation bar
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Colors.accent]
        
        // Theme the search controller
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: Colors.textOnPrimary]
        
        self.navigationBar.tintColor = Colors.accent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
