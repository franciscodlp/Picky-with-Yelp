//
//  PickyFiltersViewController.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/13/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

@objc protocol PickyFiltersViewControllerDelegate {
    optional func pickyFiltersViewController(pickyFiltersViewController: PickyFiltersViewController, didUpdateFilters filters: [String:AnyObject])
    
}


class PickyFiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PickyFiltersCategoryCellDelegate {
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var filters = [String:AnyObject]()
        // section 0
        filters["deals"] = dealsSwitchStates[0] ?? false
        // section 1
        filters["sortby"] = 0
        // section 2
        filters["distance"] = 5000
        // section 3
        var selectedCategories = [String]()
        for (row, isSelected) in categoriesSwitchStates {
            if isSelected {
                selectedCategories.append(self.categories[row]["alias"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }

        delegate?.pickyFiltersViewController!(self, didUpdateFilters: filters)
    }

    @IBOutlet var tableView: UITableView!
    
    weak var delegate: PickyFiltersViewControllerDelegate?
    
    var categories: [[String:String]]!
    
    var dealsSwitchStates = [Int:Bool]()
    var sortbySwitchStates = [Int:Bool]()
    var distanceSwitchStates = [Int:Bool]()
    var categoriesSwitchStates = [Int:Bool]()
    
    var resetButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = restaurantCategories
        
        tableView.delegate = self
        tableView.dataSource = self
        
        resetButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        resetButton.backgroundColor = UIColor.redColor()
        resetButton.titleLabel?.center = resetButton.center
        resetButton.addTarget(self, action: "resetFilters", forControlEvents: UIControlEvents.TouchUpInside)
        tableView.tableHeaderView = resetButton
        
    }
    
    func resetFilters() {
        dealsSwitchStates = [Int:Bool]()
        sortbySwitchStates = [Int:Bool]()
        distanceSwitchStates = [Int:Bool]()
        categoriesSwitchStates = [Int:Bool]()
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

// MARK: - Navigation
extension PickyFiltersViewController: UITableViewDelegate {
    
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
            return 1
        case 2:
            return 1
        case 3:
            return categories.count ?? 0
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PickyFiltersCategoryCell!
        
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
            cell.delegate = self
            cell.filterNameLabel.text = "Offering deals"
            cell.onFilterSwitch.setOn(dealsSwitchStates[indexPath.row] ?? false, animated: false)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
            cell.delegate = self
            cell.filterNameLabel.text = "Sort by"
            cell.onFilterSwitch.setOn(sortbySwitchStates[indexPath.row] ?? false, animated: false)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
            cell.delegate = self
            cell.filterNameLabel.text = "Auto"
            cell.onFilterSwitch.setOn(distanceSwitchStates[indexPath.row] ?? false, animated: false)
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
            cell.delegate = self
            cell.category = categories[indexPath.row]
            cell.onFilterSwitch.setOn(categoriesSwitchStates[indexPath.row] ?? false, animated: false)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("PickyFiltersCategoryCell", forIndexPath: indexPath) as! PickyFiltersCategoryCell
            cell.delegate = self
            cell.filterNameLabel.text = "None"
            cell.onFilterSwitch.setOn(false, animated: false)
        }
        
        
        return cell
    }
}

// MARK: - PickyFiltersBasicCellDelegate
extension PickyFiltersViewController: PickyFiltersCategoryCellDelegate {
    func pickyFiltersCategoryCell(pickyFiltersCategoryCell: PickyFiltersCategoryCell, didChangeValue value: Bool) {
        let indexPath = self.tableView.indexPathForCell(pickyFiltersCategoryCell)!
        
        switch indexPath.section{
        case 0:
            dealsSwitchStates[indexPath.row] = value
        case 1:
            sortbySwitchStates[indexPath.row] = value
        case 2:
            distanceSwitchStates[indexPath.row] = value
        case 3:
            categoriesSwitchStates[indexPath.row] = value
        default:
            println("none")
        }
//        
//        
//        println("---- 0 ----")
//        println(section0categorySwitchStates)
//        println("---- 1 ----")
//        println(section1categorySwitchStates)
//        println("---- 2 ----")
//        println(section2categorySwitchStates)
//        println("---- 3 ----")
//        println(section3categorySwitchStates)
    }
}

