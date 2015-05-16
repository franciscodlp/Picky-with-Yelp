//
//  PickyFiltersViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/13/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

@objc protocol PickyFiltersViewControllerDelegate {
    optional func pickyFiltersViewController(pickyFiltersViewController: PickyFiltersViewController, didUpdateFilters filters: [String:AnyObject], withState filtersState: [String:AnyObject])
    
}


class PickyFiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PickyFiltersCategoryCellDelegate {
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        var filters = [String:AnyObject]()
        filters["deals"] = dealsSwitchState
        filters["sortby"] = sortbyState
        filters["distance"] = distances[distanceState]
        var selectedCategories = [String]()
        for (row, isSelected) in categoriesSwitchStates {
            if isSelected {
                selectedCategories.append(self.categories[row]["alias"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        
        // Save Filters State
        var filtersState = [String:AnyObject]()
        filtersState["deals"] = dealsSwitchState
        filtersState["sortby"] = sortbyState
        filtersState["distance"] = distanceState
        filtersState["categories"] = categoriesSwitchStates

        delegate?.pickyFiltersViewController!(self, didUpdateFilters: filters, withState: filtersState)
    }

    @IBOutlet var tableView: UITableView!
    
    weak var delegate: PickyFiltersViewControllerDelegate?
    
    private var resetControl: UIRefreshControl!
    private var resetLabel: UILabel!
    
    private var shouldExpandSortBy: Bool = false
    private var shouldExpandDistance: Bool = false
    private var shouldExpandCategories: Bool = false
    
    private var categories: [[String:String]]!
    
    private let distances = [805, 1609, 8047, 16093]  // 0.5 1 5 10 miles
    private var dealsSwitchState: Bool = false
    private var sortbyState: Int = YelpSortMode.BestMatched.rawValue
    private var distanceState: Int = 0 // 0: 0.5 miles, 1: 1 mile, 2: 5 miles, 3: 10 miles
    private var categoriesSwitchStates = [Int:Bool]()
    
    var filtersState: [String:AnyObject]!
    
    private var resetButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = restaurantCategories
        
        shouldExpandDistance = false
        shouldExpandSortBy = false
        shouldExpandCategories = false
        
        resetControl = UIRefreshControl()
        resetControl.addTarget(self, action: "resetFilters", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(resetControl, atIndex: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        resetLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 14))
        resetLabel.backgroundColor = UIColor.clearColor()
        resetLabel.textAlignment = NSTextAlignment.Center
        resetLabel.font = UIFont(name: "Helvetica Neue", size: 10.0)
        resetLabel.textColor = UIColor.grayColor()
        resetLabel.text = "Pull to Reset Filters"
        tableView.tableHeaderView = resetLabel
        
        filtersState = filtersState ?? [String:AnyObject]()
        
        dealsSwitchState = filtersState?["deals"] as? Bool ?? false
        sortbyState = filtersState?["sortby"] as? Int ?? YelpSortMode.BestMatched.rawValue
        distanceState = filtersState?["distance"] as? Int ?? 0
        categoriesSwitchStates = filtersState?["categories"] as? [Int:Bool] ?? [Int:Bool]()
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        shouldExpandDistance = false
        shouldExpandSortBy = false
        shouldExpandCategories = false
    }
    
    func resetFilters() {
        dealsSwitchState = false
        sortbyState = YelpSortMode.BestMatched.rawValue
        distanceState = 0
        categoriesSwitchStates = [Int:Bool]()
        filtersState["deals"] = dealsSwitchState
        filtersState["sortby"] = sortbyState
        filtersState["distance"] = distanceState
        filtersState["categories"] = categoriesSwitchStates
        shouldExpandCategories = false
        shouldExpandDistance = false
        shouldExpandSortBy = false
        resetControl.endRefreshing()
        tableView.reloadData()
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

// MARK: - UITableViewDelegate
extension PickyFiltersViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 0 && shouldExpandSortBy == false {
            println("Cell Tapped")
            (tableView.cellForRowAtIndexPath(indexPath) as! PickyFiltersExpandableCell).iconImageView.image = UIImage(named: "circleChecked")
            var indexPathArray = [NSIndexPath(forRow: 1, inSection: indexPath.section),
                                  NSIndexPath(forRow: 2, inSection: indexPath.section),
                                  NSIndexPath(forRow: 3, inSection: indexPath.section)]
            shouldExpandSortBy = true
            tableView.insertRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.Top)
            
        } else if indexPath.section == 1 && shouldExpandSortBy == true {
            var indexPathArray = [NSIndexPath(forRow: 1, inSection: indexPath.section),
                NSIndexPath(forRow: 2, inSection: indexPath.section),
                NSIndexPath(forRow: 3, inSection: indexPath.section)]
            if indexPath.row > 0 {
                sortbyState = indexPath.row - 1
            }
            shouldExpandSortBy = false
            tableView.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.Bottom)
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section)) as! PickyFiltersExpandableCell).iconImageView.image = UIImage(named: "arrowDown")
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
            
        } else if indexPath.section == 2 && indexPath.row == 0 && shouldExpandDistance == false {
            println("Cell Tapped")
            (tableView.cellForRowAtIndexPath(indexPath) as! PickyFiltersExpandableCell).iconImageView.image = UIImage(named: "circleChecked")
            var indexPathArray = [NSIndexPath(forRow: 1, inSection: indexPath.section),
                NSIndexPath(forRow: 2, inSection: indexPath.section),
                NSIndexPath(forRow: 3, inSection: indexPath.section),
                NSIndexPath(forRow: 4, inSection: indexPath.section)]
            shouldExpandDistance = true
            tableView.insertRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.Top)
            
        } else if indexPath.section == 2 && shouldExpandDistance == true {
            var indexPathArray = [NSIndexPath(forRow: 1, inSection: indexPath.section),
                NSIndexPath(forRow: 2, inSection: indexPath.section),
                NSIndexPath(forRow: 3, inSection: indexPath.section),
                NSIndexPath(forRow: 4, inSection: indexPath.section)]
            if indexPath.row > 0 {
                distanceState = indexPath.row - 1
            }
            shouldExpandDistance = false
            tableView.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.Bottom)
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section)) as! PickyFiltersExpandableCell).iconImageView.image = UIImage(named: "arrowDown")
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
            
        } else if indexPath.section == 3 && indexPath.row == 3 {
            shouldExpandCategories = true
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
        }
        
    }
    
}


// MARK: - UITableViewDataSource
extension PickyFiltersViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 0. Deals
        // 1. Sort By
        // 2. Distance
        // 3. Categories
        return 4
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Deals"
        case 1:
            return "Sort by"
        case 2:
            return "Distance"
        case 3:
            return "Categories"
        default:
            return "Other"
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return shouldExpandSortBy ? 4 : 1
        case 2:
            return shouldExpandDistance ? 5 : 1
        case 3:
            return shouldExpandCategories ? (categories.count ?? 0) : 4
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let yelpSortModesStrings = ["Best Matched", "Distance", "Highest Rated"]
        let defaultDistancesStrings = ["0.5 miles", "1 mile", "5 miles", "10 miles" ]
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
            cell.delegate = self
            cell.filterNameLabel.text = "Offering deals"
            cell.onFilterSwitch.setOn(dealsSwitchState, animated: false)
            return cell
        case 1:
            if shouldExpandSortBy {
                let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersSortbyCell", forIndexPath: indexPath) as! PickyFiltersSortbyCell
                cell.filterNameLabel.text = yelpSortModesStrings[indexPath.row - 1]
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersExpandableCell", forIndexPath: indexPath) as! PickyFiltersExpandableCell
                cell.filterNameLabel.text = yelpSortModesStrings[sortbyState]
                cell.iconImageView.image = UIImage(named: "downArrow")
                return cell
            }

        case 2:
            if shouldExpandDistance {
                let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersDistanceCell", forIndexPath: indexPath) as! PickyFiltersDistanceCell
                cell.filterNameLabel.text = defaultDistancesStrings[indexPath.row - 1]
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersExpandableCell", forIndexPath: indexPath) as! PickyFiltersExpandableCell
                cell.filterNameLabel.text = defaultDistancesStrings[distanceState]
                cell.iconImageView.image = UIImage(named: "downArrow")
                return cell
            }
            
        case 3:
            
            if shouldExpandCategories {
                let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
                cell.delegate = self
                cell.category = categories[indexPath.row]
                cell.onFilterSwitch.setOn(categoriesSwitchStates[indexPath.row] ?? false, animated: false)
                return cell
            } else {
                if indexPath.row < 3 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
                    cell.delegate = self
                    cell.category = categories[indexPath.row]
                    cell.onFilterSwitch.setOn(categoriesSwitchStates[indexPath.row] ?? false, animated: false)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersSeeAllCell", forIndexPath: indexPath) as! PickyFiltersSeeAllCell
                    return cell
                }
            }
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
            cell.delegate = self
            cell.filterNameLabel.text = "None"
            cell.onFilterSwitch.setOn(false, animated: false)
            return cell
        }

    }
}

// MARK: - PickyFiltersBasicCellDelegate
extension PickyFiltersViewController: PickyFiltersCategoryCellDelegate {
    func pickyFiltersCategoryCell(pickyFiltersCategoryCell: PickyFiltersCategoryCell, didChangeValue value: Bool) {
        let indexPath = self.tableView.indexPathForCell(pickyFiltersCategoryCell)!
        
        switch indexPath.section{
        case 0:
            dealsSwitchState = value
        case 3:
            categoriesSwitchStates[indexPath.row] = value
        default:
            println("none")
        }

    }
}

