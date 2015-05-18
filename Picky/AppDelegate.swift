//
//  AppDelegate.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/13/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit
import CoreLocation

var restaurantCategories: [[String:String]]!


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        loadCategoriesFromYelp()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    }
    
    func loadCategoriesFromYelp() {
        var request = NSURLRequest(URL: NSURL(string: "https://s3-media2.fl.yelpcdn.com/assets/srv0/developer_pages/5e749b17ad6a/assets/json/categories.json")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            if error == nil {
                var restaurantsCategoriesRaw = [[String:AnyObject]]()
                var responseDictionary =  NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! [NSDictionary]?
                for category in responseDictionary! {
                    var parents: [String]? = category["parents"]! as? [String]
                    if let parents = parents {
                        if contains(parents, "restaurants") {
                            restaurantsCategoriesRaw.append(category as! [String:AnyObject])
                        }
                    }
                }
                restaurantCategories = [[String:String]]()
                for category in restaurantsCategoriesRaw {
                    var yelpCategory = [String:String]()
                    yelpCategory["title"] = category["title"] as? String
                    yelpCategory["alias"] = category["alias"] as? String
                    restaurantCategories.append(yelpCategory)
                }
//                                println(restaurantsCategoriesRaw)
//                                println(restaurantCategories)
            } else {
                println(error)
            }
        }
    }
}



