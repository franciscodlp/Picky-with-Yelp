//
//  PickySearchViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/12/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

class PickySearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PickyFiltersViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var businesses: [Business]!
    var topSearchBar: UISearchBar!
    var tableHeaderSearchBar: UISearchBar!
    var isSearchBarActive = false
    var tableViewRefreshControl: UIRefreshControl!
    var loadingView: UIActivityIndicatorView!
    
    struct Search {
        var term: String = "Restaurants"
        var limit: Int? = 20
        var offset: Int? = 0
        var sortby: YelpSortMode? = YelpSortMode.BestMatched
        var categories: [String]? = nil
        var radius: Int? = 10000
        var deals: Bool? = false
    }
    
    var newSearch: Search!
    var lastSearch: Search!
    var lastSearchCount: Int!
    
    @IBAction func onSearchButton(sender: AnyObject) {
        newSearch = lastSearch
        newSearch.term = tableHeaderSearchBar.text
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        searchBusinesses(search: newSearch)
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
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                self.lastSearch = self.newSearch
                self.businesses = businesses
                self.lastSearchCount = businesses.count
                businesses.count < 20 ? self.loadingView.stopAnimating() : self.loadingView.startAnimating()
                self.tableView.reloadData()
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            } else {
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                println("ERRRRRRRRRRRRR")
                println(error)
                println("ERRRRRRRRRRRRR")
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
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals) { (businesses:[Business]!, error:NSError!) -> Void in
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
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals) { (businesses:[Business]!, error:NSError!) -> Void in
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filtersVCSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! PickyFiltersViewController
            filtersViewController.delegate = self
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
        newSearch = lastSearch
        newSearch.term = tableHeaderSearchBar.text
        newSearch.offset = 0
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        searchBusinesses(search: newSearch)
    }
}

// MARK: PickyFiltersViewControllerDelegate
extension PickySearchViewController: PickyFiltersViewControllerDelegate {
    func pickyFiltersViewController(pickyFiltersViewController: PickyFiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
//        var deals = filters["deals"] as? Bool
//        println("Deals: \(deals)")
//        var sortby = filters["sortby"] as? Int
//        println("Sort by: \(sortby)")
//        var distance = filters["distance"] as? Int
//        println("Distance: \(distance)")
        
        
        newSearch = Search(term: lastSearch.term, limit: lastSearch.limit, offset: lastSearch.offset, sortby: filters["sortby"] as? YelpSortMode, categories: filters["categories"] as? [String], radius: filters["distance"] as? Int, deals: filters["deals"] as? Bool)
        
        
        Business.searchWithTerm(newSearch.term, limit: newSearch.limit, offset: newSearch.offset, sort: newSearch.sortby, categories: newSearch.categories, radius: newSearch.radius, deals: newSearch.deals) { (businesses:[Business]!, error:NSError!) -> Void in
            if error == nil {
                self.lastSearch = self.newSearch
                self.businesses = businesses
                self.lastSearchCount = businesses.count
                businesses.count < 20 ? self.loadingView.stopAnimating() : self.loadingView.startAnimating()
                self.tableView.reloadData()
            } else {
                println(error)
            }
        }
    }
}