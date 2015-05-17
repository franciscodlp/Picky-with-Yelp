//
//  PickySearchViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/12/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PickySearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PickyFiltersViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    private var businesses: [Business]!
    private var selectedBusiness: Business!
    private var topSearchBar: UISearchBar!
    private var tableHeaderSearchBar: UISearchBar!
    private var isSearchBarActive = false
    private var tableViewRefreshControl: UIRefreshControl!
    private var loadingView: UIActivityIndicatorView!

    
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
    
    private var newSearch: Search!
    private var lastSearch: Search!
    private var lastSearchCount: Int!
    
    var currentUserLocation: String!
    
    var filtersState: [String:AnyObject]!
    
    @IBAction func onSearchButton(sender: AnyObject) {
        searchButtonPressed()
    }

    override func viewDidLoad() {
        println("PickySearchViewController : viewDidLoad")
        super.viewDidLoad()
        
        // Configs Table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        var tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.center = tableFooterView.center
        loadingView.startAnimating()
        tableFooterView.addSubview(loadingView)
        tableView.tableFooterView = tableFooterView
        
        newSearch = Search()
        newSearch.location = currentUserLocation ?? "37.785771,-122.406165"
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals, location: newSearch.location) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                self.lastSearch = self.newSearch
                self.businesses = businesses
                self.lastSearchCount = businesses.count
                businesses.count < 20 ? self.loadingView.stopAnimating() : self.loadingView.startAnimating()
                self.tableView.reloadData()
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            } else {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                println(error)
            }
        }
        
        // Configs Both SearchBars
        tableHeaderSearchBar = UISearchBar()
        tableHeaderSearchBar.delegate = self
        tableHeaderSearchBar.showsCancelButton = true

        topSearchBar = UISearchBar()
        topSearchBar.delegate = self
        topSearchBar.tag = 3
        self.navigationItem.titleView = topSearchBar
        
        // Adds RefreshControl
        tableViewRefreshControl = UIRefreshControl()
        tableViewRefreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(tableViewRefreshControl, atIndex: 0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        println("PickySearchViewController : viewDidAppear")
        super.viewDidAppear(true)
        tableHeaderSearchBar.resignFirstResponder()
        topSearchBar.resignFirstResponder()
        topSearchBar.hidden = false
        isSearchBarActive = false
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onRefresh() {
        self.tableHeaderSearchBar.resignFirstResponder()
        self.topSearchBar.resignFirstResponder()
        newSearch = lastSearch
        newSearch.offset = 0
        newSearch.location = currentUserLocation ?? "37.785771,-122.406165"
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals, location: newSearch.location) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                self.tableViewRefreshControl.endRefreshing()
                self.businesses = businesses
                self.lastSearchCount = businesses.count
                businesses.count < 20 ? self.loadingView.stopAnimating() : self.loadingView.startAnimating()
                self.topSearchBar.hidden = false
                self.isSearchBarActive = false
                self.tableView.reloadData()
            } else {
                self.tableViewRefreshControl.endRefreshing()
                println(error)
            }
        }
    }
    
    func searchBusinesses(#search: Search) {
        self.tableHeaderSearchBar.resignFirstResponder()
        self.topSearchBar.resignFirstResponder()
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
                businesses.count < 20 ? self.loadingView.stopAnimating() : self.loadingView.startAnimating()
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
    
    func searchButtonPressed() {
        newSearch = lastSearch
        newSearch.term = tableHeaderSearchBar.text == "" ? "Restaurants" : tableHeaderSearchBar.text
        newSearch.offset = 0
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        searchBusinesses(search: newSearch)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchFiltersSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! PickyFiltersViewController
            filtersViewController.delegate = self
            filtersViewController.filtersState = self.filtersState
        } else if segue.identifier == "ListToDetails" {
            let detailsViewController = segue.destinationViewController as! PickyDetailsViewController
            detailsViewController.business = selectedBusiness
        }
        
    }

    
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
        cell.business = self.businesses[indexPath.row]
        // Infinite scroll
        if ( indexPath.row == (businesses.count - 1) ) && ( self.lastSearchCount == 20 ){
            newSearch = lastSearch
            lastSearch.offset = businesses.count
            searchBusinesses(search: lastSearch)
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension PickySearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedBusiness = businesses[indexPath.row]
        return indexPath
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
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
        self.tableHeaderSearchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if searchBar.tag == 3 {
            self.topSearchBar.hidden = true
            self.isSearchBarActive = true
            self.tableHeaderSearchBar.text = ""
            tableView.reloadData()
            self.tableHeaderSearchBar.becomeFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchButtonPressed()
    }
}

// MARK: PickyFiltersViewControllerDelegate
extension PickySearchViewController: PickyFiltersViewControllerDelegate {
    func pickyFiltersViewController(pickyFiltersViewController: PickyFiltersViewController, didUpdateFilters filters: [String : AnyObject], withState filtersState: [String : AnyObject]) {
        
        self.filtersState = filtersState
        (self.tabBarController!.viewControllers![0].topViewController as? PickyMapViewController)?.filtersState = filtersState
        
        newSearch = Search(term: lastSearch.term, limit: lastSearch.limit, offset: 0, sortby: filters["sortby"] as? YelpSortMode, categories: filters["categories"] as? [String], radius: filters["distance"] as? Int, deals: filters["deals"] as? Bool,  location: lastSearch.location)
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals, location: newSearch.location) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                self.lastSearch = self.newSearch
                self.businesses = businesses
                self.lastSearchCount = businesses.count
                businesses.count < 20 ? self.loadingView.stopAnimating() : self.loadingView.startAnimating()
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                self.tableView.reloadData()
            } else {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                println(error)
            }
        }
    }
    
    func pickyFiltersViewController(pickyFiltersViewController: PickyFiltersViewController, didResetFilters filtersState: [String : AnyObject]) {
        self.filtersState = filtersState
        (self.tabBarController!.viewControllers![0].topViewController as? PickyMapViewController)?.filtersState = filtersState
    }
}


