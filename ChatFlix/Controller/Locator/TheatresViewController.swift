//
//  TheatresViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 29/4/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import MapKit

class TheatresViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation: CLLocationCoordinate2D?
    var currentTitle: String?
    
    var theatres: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAnnotation(title: currentTitle!, coordinate: currentLocation!)
        focusOn(coordinate: currentLocation!)
        
        // Use helper function to pinpoint theatres
        annotateTheatres()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func annotateTheatres() {
        // Expand region
        let regionRadius: CLLocationDistance = 15000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation!, regionRadius * 2.0, regionRadius * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
        
        // Make a request to find places of interest with "Movie"
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Movie Theatres"
        request.region = mapView.region
        
        // Start searching
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { (response, error) in
            if error != nil {
                self.displayErrorMessage(error!.localizedDescription)
            } else if response!.mapItems.count == 0 {
                self.displayErrorMessage("No Movies Theatres found in this area")
            } else {
                for item in response!.mapItems {
                    // Append to our list
                    self.theatres.append(item)
                    // Add item annotation
                    self.addAnnotation(title: item.name!, coordinate: item.placemark.coordinate)
                }
            }
        })
    }
    
    func addAnnotation(title: String, lat: Double, long: Double) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.mapView.addAnnotation(annotation)
    }
    
    func addAnnotation(title: String, coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    func focusOn(annotation: MKPointAnnotation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
        self.mapView.selectAnnotation(annotation, animated: true)
    }
    
    func focusOn(coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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
