//
//  PickyDetailsViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/16/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit
import MapKit

class PickyDetailsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoriesLabel: UILabel!
    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var numberOfReviewsLabel: UILabel!
    @IBOutlet var addressLine1Label: UILabel!
    @IBOutlet var addressLine2Label: UILabel!
    
    @IBAction func onCallButton(sender: AnyObject) {
        println("botton pressed")
        if business.phone != nil {
            println("about to call")
            let url = NSURL(string: "tel://" + business.phone!)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    @IBOutlet var favoriteButton: UIButton!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBAction func saveToFavoritesButton(sender: AnyObject) {
        
        if business != nil {
            Business.saveBusinessWithId(business, businessId: business.yelpID!)
            var favoritesBusinessArray = NSUserDefaults.standardUserDefaults().objectForKey("favoritesBusinessArray") as? [String]
            if favoritesBusinessArray == nil {
                favoritesBusinessArray = [String]()
            }
            favoritesBusinessArray!.append(business.yelpID!)
            NSUserDefaults.standardUserDefaults().setObject(favoritesBusinessArray, forKey: "favoritesBusinessArray")
        }
        
        favoriteButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.favoriteButton.transform = CGAffineTransformIdentity
            }, completion: { (success:Bool) -> Void in
                
        })
        
    }
    
    let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    var business: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        
        nameLabel.text = business.name!
        categoriesLabel.text = business.categories!
        ratingImageView.setImageWithURL(business.ratingImageURL!)
        numberOfReviewsLabel.text = "\(business.reviewCount!) reviews"
        addressLine1Label.text = business.addressArray![0]
        addressLine2Label.text = business.addressArray![1]
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: business.coordinate!["latitude"] as! CLLocationDegrees, longitude: business.coordinate!["longitude"] as! CLLocationDegrees), span: span), animated: false)
        var pickyAnnotation = PickyAnnotation(coordinate: CLLocationCoordinate2D(latitude: business.coordinate!["latitude"] as! CLLocationDegrees, longitude: business.coordinate!["longitude"] as! CLLocationDegrees),
            title: business.name!,
            subtitle: business.categories!, business: business)
        mapView.addAnnotation(pickyAnnotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: MKMapViewDelegate
extension PickyDetailsViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationView2") as? MKPinAnnotationView
        
        if annotationView == nil {
            var newAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView2")
            newAnnotationView.image = UIImage(named: "Pin1")
            annotationView = newAnnotationView
        }
        
        return annotationView
    }
    
}