//
//  PickySearchViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/12/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

class PickySearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var businesses: [Business]!
    
    @IBOutlet var altSearchBar: UISearchBar!
    
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        Business.searchWithTerm("Restaurants", limit: nil, offset: nil, sort: .Distance, categories: ["pizza", "burgers"], radius: nil, deals: nil) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                self.businesses = businesses
                self.tableView.reloadData()
            } else {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                println(error)
            }
        }
        
        altSearchBar.tag = 1
        altSearchBar.delegate = self
        altSearchBar.showsCancelButton = true
        altSearchBar.frame = CGRect(origin: altSearchBar.frame.origin, size: CGSize(width: self.altSearchBar.frame.size.width, height: 0.0))
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.tag = 0
        self.navigationItem.titleView = searchBar
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //        self.searchBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBarTapped(sender: UIButton) {
        
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
////////////////////////////////////////////////////////

// MARK: UITableViewDataSource

extension PickySearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PickySearchBusinessCell", forIndexPath: indexPath) as! PickySearchBusinessCell
        println(self.businesses[indexPath.row])
        cell.business = self.businesses[indexPath.row]
        println(self.businesses[indexPath.row].deals!)
        return cell
    }
}

// MARK: UITableViewDelegate

extension PickySearchViewController: UITableViewDelegate {
    
}

// MARK: UISearchBarDelegate

extension PickySearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if searchBar.tag == 1 {
            self.searchBar.hidden = false
            self.altSearchBar.frame = CGRect(origin: self.altSearchBar.frame.origin, size: CGSize(width: self.altSearchBar.frame.size.width, height: 0.0))
            self.altSearchBar.resignFirstResponder()
            self.tableView.reloadData()
        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if searchBar.tag == 0 {
            searchBar.hidden = true
            self.altSearchBar.frame = CGRect(origin: self.altSearchBar.frame.origin, size: CGSize(width: self.altSearchBar.frame.size.width, height: 44.0))
            self.altSearchBar.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.tableView.reloadData()
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 3.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.altSearchBar.transform = CGAffineTransformIdentity
                }) { (success:Bool) -> Void in
                    self.altSearchBar.becomeFirstResponder()
            }
        }
    }
}