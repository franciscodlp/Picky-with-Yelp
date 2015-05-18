//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Business: NSObject, NSCoding {
    let yelpID: String?
    let name: String?
    let imageURL: NSURL?
    let address: String?
    let addressArray: [String]?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    let deals: Bool?
    let coordinate: NSDictionary?
    let phone: String?
    
    
    init(dictionary: NSDictionary) {
        yelpID = dictionary["id"] as? String
        
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        self.phone = dictionary["phone"] as? String
        println(self.phone)
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        var displayAddress = [String]()
        if location != nil {
            let locationCoordinate = location!["coordinate"] as? NSDictionary
            if locationCoordinate != nil {
                coordinate = locationCoordinate
            } else {
                coordinate = nil
            }
            
            let addressArray = location!["address"] as? NSArray
            var street: String? = ""
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let addressTempArray = location!["display_address"] as? [String]
            
            if addressTempArray != nil {
                for line in addressTempArray! {
                    displayAddress.append(line)
                }
            }
            
            var neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        } else {
            coordinate = nil
        }

        self.address = address
        self.addressArray = displayAddress
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                var categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = ", ".join(categoryNames)
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
        
        let isDealAvailable = dictionary["deals"] as? [AnyObject]
        
        if isDealAvailable != nil {
            deals = true
        } else {
            deals = false
        }
    }
    
    override init() {
        self.yelpID = String()
        self.name = String()
        self.imageURL = NSURL()
        self.address = String()
        self.addressArray = [String]()
        self.categories = String()
        self.distance = String()
        self.ratingImageURL = NSURL()
        self.reviewCount = NSNumber()
        self.deals = Bool()
        self.coordinate = NSDictionary()
        self.phone = String()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let yelpID = self.yelpID { aCoder.encodeObject(yelpID, forKey: "yelpID") }
        if let name = self.name { aCoder.encodeObject(name, forKey: "name") }
        if let imageURL = self.imageURL { aCoder.encodeObject(imageURL, forKey: "imageURL") }
        if let address = self.address { aCoder.encodeObject(address, forKey: "address") }
        if let addressArray = self.addressArray { aCoder.encodeObject(addressArray, forKey: "addressArray") }
        if let categories = self.categories { aCoder.encodeObject(categories, forKey: "categories") }
        if let distance = self.distance { aCoder.encodeObject(distance, forKey: "distance") }
        if let ratingImageURL = self.ratingImageURL { aCoder.encodeObject(ratingImageURL, forKey: "ratingImageURL") }
        if let reviewCount = self.reviewCount { aCoder.encodeObject(reviewCount, forKey: "reviewCount") }
        if let reviewCount = self.reviewCount { aCoder.encodeObject(deals, forKey: "deals") }
        if let coordinate = self.coordinate { aCoder.encodeObject(coordinate, forKey: "coordinate") }
        if let phone = self.phone { aCoder.encodeObject(phone, forKey: "phone") }
    }
    
    required init(coder aDecoder: NSCoder) {
            self.yelpID = aDecoder.decodeObjectForKey("yelpID") as? String
            self.name = aDecoder.decodeObjectForKey("name") as? String
            self.imageURL = aDecoder.decodeObjectForKey("imageURL") as? NSURL
            self.address = aDecoder.decodeObjectForKey("address") as? String
            self.addressArray = aDecoder.decodeObjectForKey("addressArray") as? [String]
            self.categories = aDecoder.decodeObjectForKey("categories") as? String
            self.distance = aDecoder.decodeObjectForKey("distance") as? String
            self.ratingImageURL = aDecoder.decodeObjectForKey("ratingImageURL") as? NSURL
            self.reviewCount = aDecoder.decodeObjectForKey("reviewCount") as? NSNumber
            self.deals = aDecoder.decodeObjectForKey("deals") as? Bool
            self.coordinate = aDecoder.decodeObjectForKey("coordinate") as? NSDictionary
            self.phone = aDecoder.decodeObjectForKey("phone") as? String
    }
    
    class func saveBusinessWithId(business: Business, businessId: String) {
        var encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(business.self)
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(encodedObject, forKey: businessId)
        defaults.synchronize()
    }
    
    
    
    class func loadBusinessWithId(businessId: String) -> Business? {
        var defaults = NSUserDefaults.standardUserDefaults()
        var encodedOnject: NSData? = defaults.objectForKey(businessId) as? NSData
        if encodedOnject == nil {
            return nil
        }
        var business: Business? = NSKeyedUnarchiver.unarchiveObjectWithData(encodedOnject!) as? Business
        return business
    }
    
    class func businesses(#array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            var business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func searchWithTerm(term: String, limit: Int?, offset: Int?, sort: YelpSortMode?, categories: [String]?, radius: Int?, deals: Bool?, location: String?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, limit: limit, offset: offset, sort: sort, categories: categories, radius: radius, deals: deals, location: location, completion: completion)
    }
    //    class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> Void {
    //        YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, completion: completion)
    //    }
}
