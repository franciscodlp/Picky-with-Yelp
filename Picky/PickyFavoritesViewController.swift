//
//  PickyFavoritesViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/17/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

class PickyFavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    private var businesses: [Business]!
    private var selectedBusiness: Business!
    
    let grayColor = UIColor(red: (90.0 / 255.0), green: (95.0 / 255.0), blue: (85.0 / 255.0), alpha: 1)
    let orangeColor = UIColor(red: (245.0 / 255.0), green: (166.0 / 255.0), blue: (35.0 / 255.0), alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.barTintColor = grayColor
        self.tabBarController?.tabBar.tintColor = orangeColor
        
        
        self.navigationController?.navigationBar.backgroundColor = grayColor
        self.navigationController?.navigationBar.barTintColor = grayColor
        self.navigationController?.navigationBar.tintColor = orangeColor
        self.navigationController?.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: orangeColor], forState: UIControlState.Normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        

        var favoritesBusinessArray = NSUserDefaults.standardUserDefaults().objectForKey("favoritesBusinessArray") as? [String]
        
        if favoritesBusinessArray != nil {
            businesses = [Business]()
            for item in favoritesBusinessArray! {
                var business = Business.loadBusinessWithId(item)
                businesses.append(business!)
            }
            
        }
        
        if businesses == nil {
            var imageView = UIImageView(frame: self.tableView.frame)
            imageView.image = UIImage(named: "heart")
            tableView.backgroundView = imageView
        } else {
            tableView.backgroundView = nil
        }

        // Do any additional setup after loading the view.
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FavoritesToDetails" {
            let detailsViewController = segue.destinationViewController as! PickyDetailsViewController
            detailsViewController.business = selectedBusiness
        }
    }


}

// MARK: UITableViewDataSource

extension PickyFavoritesViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return businesses == nil ? 0 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PickyFavoriteBusinessCell", forIndexPath: indexPath) as! PickySearchBusinessCell
        cell.business = businesses![indexPath.row]
        return cell
    }
}

// MARK: UITableViewDelegate

extension PickyFavoritesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedBusiness = businesses[indexPath.row]
        return indexPath
    }
}