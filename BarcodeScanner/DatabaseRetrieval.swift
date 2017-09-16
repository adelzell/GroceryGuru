//
//  DatabaseRetrieval.swift
//  BarcodeScanner
//
//  Created by Amelia Delzell on 4/15/17.
//  Copyright © 2017 Amelia Delzell. All rights reserved.
//  Adapted from Chris Ching's tutorial "The Best Way to Connect Your iOS App to My SQL Database https://codewithchris.com/iphone-app-connect-to-mysql-database/ 
//

import Foundation
import UIKit
protocol DataServiceProtocol: class{
    func itemsDownloaded(items: NSArray)
}

class DatabaseRetrieval: NSObject, URLSessionDataDelegate {


    var delegate1: DataServiceProtocol!

    var data : NSMutableData = NSMutableData()

    let urlPath: String = "http://thepawsngo.com/service.php"

    func downloadItems(){
        

        let url: URL = URL(string: urlPath)!
        var session: URLSession
        let configuration = URLSessionConfiguration.ephemeral

        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: url)

        task.resume()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        self.data.append(data);
        
    }
    
    //downloads data and turns the database into a JSON file and then into an array of items using the parseJSON function

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        if error != nil{
            print(error ?? " ")
            print("Failed to download data")
        }
        else{
            print("Data downloaded")
            self.parseJSON()
        }
    }

    func parseJSON() {
        var jsonResult: NSArray = NSArray()

        do{
            jsonResult = try JSONSerialization.jsonObject(with: self.data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray

        } catch let error as NSError{
            print(error)
        }

        var jsonElement: NSDictionary = NSDictionary()
        let itemsArray: NSMutableArray = NSMutableArray()

        for i in 0 ..< jsonResult.count
        {

            jsonElement = jsonResult[i] as! NSDictionary
            
            let item = Item()

            if let UPC = jsonElement["UPC"] as? String{
                item.UPC = UPC
            }
            if let name = jsonElement["Name"] as? String{
                item.name = name
            }
            if let price = jsonElement["Price"] as? String{
                item.price = price
            }
            if let stock = jsonElement["Stock"] as? String{
                item.stock = stock
            }
            
            itemsArray.add(Item: item)
        }
        DispatchQueue.main.async(execute: { () -> Void in
                self.delegate1.itemsDownloaded(items: itemsArray)
            })
        }

}


