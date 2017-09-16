//
//  SetStockViewController.swift
//  BarcodeScanner
//
//  Created by Amelia Delzell on 4/18/17.
//  Copyright © 2017 Amelia Delzell. All rights reserved.
//  Adapted from Apple's Start Developing Apps Sample Project: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/
//  Adapted from Belal Khan's Swift PHP MySQL Tutorial – Connecting iOS App to MySQL Database: https://www.simplifiedios.net/swift-php-mysql-tutorial/

//

import UIKit
import os.log


class SetStockViewController: UIViewController, UINavigationControllerDelegate  {

    var item: Item?
    let URL_UPDATE_STOCK = "http://thepawsngo.com/combine.php"
    var itemTable = ItemTableViewController()
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stockLabel: UILabel!
    
    override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
        
        self.stock.text = "How many in stock?"
        
        let when = DispatchTime.now() + 0.05 // delays for a period of time to allow the program to search for the desired item
            DispatchQueue.main.asyncAfter(deadline: when) {
            if (DataService.dataService.NAME_OF_FOOD != " "){
                self.nameLabel.text = "Add " + DataService.dataService.NAME_OF_FOOD + " to your cart?"
            }
            else {
                self.nameLabel.text = "Item not stored in databse. Add it to list anyways?"
            }
        }
    
    updateSaveButtonState()
    
    }
    
    //saves the item to the gorcery list and updates the stock in the cloud database
    
   @IBAction func save(_ sender: UIButton) {
        let requestURL = URL(string: URL_UPDATE_STOCK)
        
        var request = URLRequest(url: requestURL!)
    
        
        request.httpMethod = "POST"
        
        let UPC = DataService.dataService.UPC
        let newStock = Int(slider.value)
        var stock = " "
        if (newStock == 6) {
            stock = "5%2B"
        }
        else {
            stock = String(newStock-1)
        }
    
        print(stock)
    
        let postParameters = "UPC="+UPC+"&Stock="+stock;
    
        print(postParameters)
        
        request.httpBody = postParameters.data(using: .utf8)
    
        print(request)
    
    if newStock != 0 {
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
    
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
                self.itemTable.reload()
                print("reload")
        }
        task.resume()
    }
    else {
        self.itemTable.reload()
    }
   }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        
        if (currentValue == 0){
            self.stockLabel.text = "N/A"
            
        }
        else if (currentValue == 6) {
            self.stockLabel.text = "5+"
        }
        else {
            self.stockLabel.text = String(currentValue-1)
        }
    }
    

    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIButton, button === saveButton else {
            if #available(iOS 10.0, *) {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            }
            return
        }
        
        let newStock = Int(slider.value) - 1
        let name = DataService.dataService.NAME_OF_FOOD
        let photo = DataService.dataService.IMAGE
        let stock = String(newStock)
        let UPC = DataService.dataService.UPC
        let price = DataService.dataService.PRICE_OF_FOOD
        
        
        // Set the item to be passed to ItemTableViewController after the unwind segue.
        item = Item(name: name, photo: photo, price: price, stock: stock, UPC: UPC)
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInSetStockMode = presentingViewController is UINavigationController
        let owningNavigationController = navigationController
        
        if isPresentingInSetStockMode || (owningNavigationController != nil) {
            dismiss(animated: true, completion: nil)
        }
        else {
            fatalError("The ItemViewController is not inside a navigation controller.")
        }
    }
    
    private func updateSaveButtonState() {
       saveButton.isEnabled = true
    }
}
