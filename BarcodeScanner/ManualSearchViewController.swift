//
//  ManualSearchViewController.swift
//  BarcodeScanner
//
//  Created by Amelia Delzell on 4/16/17.
//  Copyright © 2017 Amelia Delzell. All rights reserved.
//  Used techniques from Gabriel Theodoropoulos' tutorial "How To Create a Custom Search Bar Using UISearchController": https://www.appcoda.com/custom-search-bar-tutorial/
//

import Foundation
import UIKit

class ManualSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tblSearchResults: UITableView!
    static var itemsArray = NSArray()
    var filteredArray = Array<String>()
    var shouldShowResults = false
    var searchController: UISearchController!
    var selectedItem = String()
    var itemTable = ItemTableViewController()
    
    
    
    static func itemsReceived(items: NSArray){
        print("tableReload")
        itemsArray = items
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        configureSearchController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tblSearchResults.tableHeaderView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowResults = true
        tblSearchResults.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tblSearchResults.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (!shouldShowResults) {
            shouldShowResults = true
            tblSearchResults.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
        tblSearchResults.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those items that match the search text.
        let a = ManualSearchViewController.itemsArray.count
        var unfilteredArray = Array(repeating: " ", count: a)
        for i in 0 ..< a{
            unfilteredArray[i] = (ManualSearchViewController.itemsArray[i] as! Item).name!
            
        }
        filteredArray = unfilteredArray.filter({ (foodName) -> Bool in
            let foodText: NSString = foodName as NSString
            return (foodText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
        tblSearchResults.reloadData()
    }
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    
    //creates a table with only the amount of rows as match the search criteria
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredArray.count
        }
        else {
            return ManualSearchViewController.itemsArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "happy"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as?
            ManualSearchTableViewCell else{
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }

        if shouldShowResults {
            cell.stockLabel.text = DataService.getStock(name: filteredArray[indexPath.row])
            cell.nameLabel.text = filteredArray[indexPath.row]
        }
        else {
            let name = (ManualSearchViewController.itemsArray[indexPath.row] as! Item).name
            let stock = (ManualSearchViewController.itemsArray[indexPath.row] as! Item).stock
            cell.nameLabel.text = name
            cell.stockLabel.text = stock
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            selectedItem = filteredArray[indexPath.row]
            DataService.searchAPI(name: selectedItem)
        }
        
        else {
            selectedItem = (ManualSearchViewController.itemsArray[indexPath.row] as! Item).name!
            DataService.searchAPI(name: selectedItem)
        }
        
    }

}

