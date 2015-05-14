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
    var topSearchBar: UISearchBar!
    var tableHeaderSearchBar: UISearchBar!
    var isSearchBarActive = false
    
    @IBAction func onSearchButton(sender: AnyObject) {
        searchBarTapped()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        Business.searchWithTerm("Restaurants", limit: nil, offset: nil, sort: .Distance, categories: ["pizza", "burgers"], radius: nil, deals: nil) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                self.businesses = businesses
                self.tableView.reloadData()
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            } else {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                println(error)
            }
        }
        tableHeaderSearchBar = UISearchBar()
        tableHeaderSearchBar.delegate = self
        tableHeaderSearchBar.showsCancelButton = true

        topSearchBar = UISearchBar()
        topSearchBar.delegate = self
        topSearchBar.tag = 3
        self.navigationItem.titleView = topSearchBar
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        topSearchBar.hidden = false
        isSearchBarActive = false
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBarTapped() {
        self.tableHeaderSearchBar.resignFirstResponder()
        self.topSearchBar.resignFirstResponder()
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        Business.searchWithTerm(tableHeaderSearchBar.text, limit: 20, offset: 0, sort: YelpSortMode.BestMatched, categories: nil, radius: nil, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            if error == nil {
                self.businesses = businesses
                self.topSearchBar.hidden = false
                self.isSearchBarActive = false
                self.tableView.reloadData()
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            } else {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                println(error)
            }
        }
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isSearchBarActive ? 44 : 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderSearchBar
    }
}

// MARK: UISearchBarDelegate

extension PickySearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.topSearchBar.hidden = false
        self.isSearchBarActive = false
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if searchBar.tag == 3 {
            self.topSearchBar.hidden = true
            self.isSearchBarActive = true
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBarTapped()
    }
}