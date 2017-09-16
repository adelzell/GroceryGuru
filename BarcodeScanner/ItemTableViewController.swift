//
//  ItemTableViewController.swift
//  BarcodeScanner
//
//  Created by Amelia Delzell on 4/16/17.
//  Copyright © 2017 Amelia Delzell. All rights reserved.
//  Code edited from Apple's Start Developing Apps Sample Project: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/
//

import UIKit
import os.log

class ItemTableViewController: UITableViewController, DataServiceProtocol {
    
    //MARK: Properties
    
    
    var feedItems: NSArray = NSArray()
    var scannedItem: Item = Item()
    var price: Double = Double()
    var didCheckOutofStock = false
    
    @IBOutlet weak var totalPrice: UILabel!
    var items = [Item]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //retrieve all data from the database
        
        let databaseRetrieval = DatabaseRetrieval()
        databaseRetrieval.delegate1 = self
        databaseRetrieval.downloadItems()
        
        totalPrice.text = "   Total Cost:"
        
        // Load any saved items
        if let savedItems = loadItems() {
            items += savedItems
            setPrice()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // check to see if any items are running low or are out of stock
        if (!didCheckOutofStock){
        isOutofStock(index: 0)
        didCheckOutofStock = true
        }
    }
    
    // goes through the items saved on the gorcery list and alerts uset if the stock is running low
    func isOutofStock(index: Int) {
        if items.count > 0 {
            let stock = DataService.getStock(name: items[index].name!)
            if (Int(stock) == 0){
                let alert = UIAlertController(title: " Item out of stock!", message: items[index].name!, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: { action in
                    if (index + 1 < self.items.count){
                        self.isOutofStock(index: index + 1)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else if (Int(stock) == 1) {
                let alert = UIAlertController(title: "Only one more remaining!", message: items[index].name!, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: { action in
                    if (index + 1 < self.items.count){
                        self.isOutofStock(index: index + 1)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                if (index + 1 < self.items.count){
                    self.isOutofStock(index: index + 1)
                }
            }
        }
    }
    
    // sums the price of all items on Grocery List
    func setPrice() {
        price = 0.00
        if items.count > 0{
        for i in 0 ..< items.count{
            price += Double(items[i].price!)!
        }
        price = Double(round(100*price)/100)
        print(price)
        }
        totalPrice.text = "  Total Cost: $" + String(price)
    }
    
    //reloads the data from the database to check and see if the stock of any items has been updated
    func reload(){
        let databaseRetrieval = DatabaseRetrieval()
        databaseRetrieval.delegate1 = self
        print(databaseRetrieval.delegate1)
        databaseRetrieval.downloadItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func itemsDownloaded(items: NSArray) {
        feedItems = items
        DataService.itemsReceived(items: items)
        ManualSearchViewController.itemsReceived(items: items)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else{
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }
        
        //Fetches the appropriate item for the data source layout.
        let item = items[indexPath.row]
        
        cell.selectionStyle = UITableViewCellSelectionStyle(rawValue: 0)!
        
        cell.name.text = item.name
        cell.photo.image = item.photo
        cell.price.text = item.price
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    //     Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            setPrice()
            saveItems()
            //Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    //MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            if #available(iOS 10.0, *) {
                os_log("Adding a new item.", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
        case "ViewFavorites":
            if #available(iOS 10.0, *) {
                os_log("Adding a new item.", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
        case "AddFavorites":
            if #available(iOS 10.0, *) {
                os_log("Adding a new item.", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    //adds a new item to the grocery list
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SetStockViewController, let item = sourceViewController.item {
                // Add a new item.
                let newIndexPath = IndexPath(row: items.count, section: 0)
            
                items.append(item)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)

            
            // Save the items.
            setPrice()
            saveItems()
            
            
            //let's the user know if the item they are adding to their cart is out of stock
            let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
            if (Int(item.stock!) == -1){
                let stock = DataService.getStock(name: item.name!)
                if (Int(stock)! == 0){
                let alert = UIAlertController(title: "Item out of stock!", message: item.name, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: nil))
                 self.present(alert, animated: true, completion: nil)
                }
                }
            }
        }
    }
    // archives items so that if the app is closed an reopened, the items on the grocery list can be reloaded
        private func saveItems() {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
            if isSuccessfulSave {
                if #available(iOS 10.0, *) {
                    os_log("Items successfully saved.", log: OSLog.default, type: .debug)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                if #available(iOS 10.0, *) {
                    os_log("Failed to save items...", log: OSLog.default, type: .error)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    // loads save items from the archives
    private func loadItems() -> [Item]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]
    }
}
