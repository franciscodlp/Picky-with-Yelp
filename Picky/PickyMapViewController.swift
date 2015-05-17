//
//  PickyMapViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/16/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PickyAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String!
    var subtitle: String!
    var business: Business!
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, business: Business) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.business = business
    }
}


class PickyMapViewController: UIViewController, UISearchBarDelegate, PickyFiltersViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBAction func onSearchButton(sender: AnyObject) {
        searchButtonPressed()
    }
    
    struct Search {
        var term: String = "Restaurants"
        var limit: Int? = 20
        var offset: Int? = 0
        var sortby: YelpSortMode? = YelpSortMode.BestMatched
        var categories: [String]? = nil
        var radius: Int? = 10000
        var deals: Bool? = false
        var location: String? = nil
    }
    
    
    var businesses: [Business]!
    
    private var searchBar: UISearchBar!
    var filtersState: [String:AnyObject]!
    private var locationManager: CLLocationManager!
    private var shouldUpdateSearchOnUserLocationUpdate: Bool! = false
    
    private var newSearch: Search!
    private var lastSearch: Search!
    private var lastSearchCount: Int!
    
    private var currentUserLocation: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar()
        searchBar.tintColor = UIColor(red: (245.0 / 255.0), green: (166.0 / 255.0), blue: (35.0 / 255.0), alpha: 1)
        
        self.tabBarController?.tabBar.tintColor = UIColor(red: (90.0 / 255.0), green: (95.0 / 255.0), blue: (85.0 / 255.0), alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor(red: (90.0 / 255.0), green: (95.0 / 255.0), blue: (85.0 / 255.0), alpha: 1)
        self.tabBarController?.tabBar.tintColor = UIColor(red: (245.0 / 255.0), green: (166.0 / 255.0), blue: (35.0 / 255.0), alpha: 1)
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: (90.0 / 255.0), green: (95.0 / 255.0), blue: (85.0 / 255.0), alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: (90.0 / 255.0), green: (95.0 / 255.0), blue: (85.0 / 255.0), alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: (245.0 / 255.0), green: (166.0 / 255.0), blue: (35.0 / 255.0), alpha: 1)
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        mapView.rotateEnabled = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        var span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.770772, longitude: -122.403923)
        var region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: false)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        shouldUpdateSearchOnUserLocationUpdate = true
        
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            println("NotDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            println("Restricted or Denied")
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            println("AuthorizedWhenInUse or AuthorizedAlways")
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        loadAnnotationsToMap(businesses)
    }
    
    func searchButtonPressed() {
        newSearch = lastSearch ?? Search()
        newSearch.term = searchBar.text == "" ? "Restaurants" : searchBar.text
        newSearch.offset = 0
        searchBusinesses(search: newSearch)
    }
    
    func searchBusinesses(#search: Search) {
        mapView.removeAnnotations(mapView.annotations)
        self.searchBar.resignFirstResponder()
        if search.offset! == 0 {
            MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        }
        
        newSearch = search
        newSearch.location = currentUserLocation ?? "37.785771,-122.406165"
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals, location: newSearch.location) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                println("Offset: \(search.offset)")
                self.lastSearch = search
                self.businesses = search.offset! == 0 ? businesses : self.businesses! + businesses
                self.lastSearchCount = businesses.count
                self.loadAnnotationsToMap(businesses)
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            } else {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                println(error)
            }
        }
    }
    
    func loadAnnotationsToMap(businesses: [Business]?) {
        if businesses != nil {
            var annotations: [PickyAnnotation] = [PickyAnnotation]()
            for singleBusiness in businesses! {
                var pickyAnnotation = PickyAnnotation(coordinate: CLLocationCoordinate2D(latitude: singleBusiness.coordinate!["latitude"] as! CLLocationDegrees, longitude: singleBusiness.coordinate!["longitude"] as! CLLocationDegrees),
                    title: singleBusiness.name!,
                    subtitle: singleBusiness.categories!, business: singleBusiness)
                annotations.append(pickyAnnotation)
            }
            mapView.addAnnotations(annotations)
        }
    }
    
    func goToDetails(sender: UIButton) {
        var biz = ((sender.superview!.superview!.superview!.superview!.superview!.superview!.superview!.superview! as! MKAnnotationView).annotation as! PickyAnnotation).business
        println(biz.name)
        var detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailsViewController") as! PickyDetailsViewController
        detailVC.business = biz
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MapFiltersSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! PickyFiltersViewController
            filtersViewController.delegate = self
            filtersViewController.filtersState = self.filtersState
        } else if segue.identifier == "MapToDetails" {

        }
    }

}

////////////////////////////////////////////////////////

// MARK: PickyFiltersViewControllerDelegate
extension PickyMapViewController: PickyFiltersViewControllerDelegate {
    func pickyFiltersViewController(pickyFiltersViewController: PickyFiltersViewController, didUpdateFilters filters: [String : AnyObject], withState filtersState: [String : AnyObject]) {
        
        self.filtersState = filtersState
        (self.tabBarController!.viewControllers![1].topViewController as? PickySearchViewController)?.filtersState = filtersState

        newSearch = Search(term: lastSearch.term, limit: lastSearch.limit, offset: 0, sortby: filters["sortby"] as? YelpSortMode, categories: filters["categories"] as? [String], radius: filters["distance"] as? Int, deals: filters["deals"] as? Bool, location: lastSearch.location)
        searchBusinesses(search: newSearch)
    }
    
    func pickyFiltersViewController(pickyFiltersViewController: PickyFiltersViewController, didResetFilters filtersState: [String : AnyObject]) {
        self.filtersState = filtersState
        (self.tabBarController!.viewControllers![1].topViewController as? PickySearchViewController)?.filtersState = filtersState
    }
}

    // MARK: UISearchBarDelegate

extension PickyMapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchButtonPressed()
    }
}


    // MARK: CLLocationManagerDelegate
extension PickyMapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("didChangeAuthorizationStatus")
        switch status {
        case .NotDetermined:
            println("NotDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            println("Restricted or Denied")
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            println("AuthorizedWhenInUse or AuthorizedAlways")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
}

    // MARK: MKMapViewDelegate
extension PickyMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        currentUserLocation = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
        (self.tabBarController!.viewControllers![1].topViewController as? PickySearchViewController)?.currentUserLocation = currentUserLocation
        
        if shouldUpdateSearchOnUserLocationUpdate! {
            shouldUpdateSearchOnUserLocationUpdate = false
            mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
            newSearch = lastSearch ?? Search()
            searchBusinesses(search: newSearch)
            
            var userLocationAnnotation = MKPointAnnotation()
            userLocationAnnotation.coordinate = userLocation.coordinate
            userLocationAnnotation.title = "You"
            mapView.addAnnotation(userLocationAnnotation)
            
            mapView.showsUserLocation = false

        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationView") as? MKPinAnnotationView
        
        if annotation.title == "You" {
            var newAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "UserPin")
            newAnnotationView.pinColor = MKPinAnnotationColor.Red
            newAnnotationView.canShowCallout = false
            return newAnnotationView
        }
        
        if annotationView == nil {
            var newAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
            newAnnotationView.image = UIImage(named: "Pin1")
            newAnnotationView.canShowCallout = true
            var callOutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            callOutButton.setImage(UIImage(named: "rightArrow"), forState: UIControlState.Normal)
            callOutButton.addTarget(self, action: "goToDetails:", forControlEvents: UIControlEvents.TouchUpInside)
            newAnnotationView.rightCalloutAccessoryView = callOutButton
            annotationView = newAnnotationView
        }

        return annotationView
    }
    
}












