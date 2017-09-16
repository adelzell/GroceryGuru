//
//  Product.swift
//  BarcodeScanner
//
//  Created by Amelia Delzell on 3/26/17.
//  Copyright © 2017 Amelia Delzell. All rights reserved.
//  Code adapted from Apple's Start Developing Apps Sample Project: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/
//


import Foundation
import UIKit
import os.log

class Item: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String?
    var photo: UIImage?
    var price: String?
    var stock: String?
    var UPC: String?
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    
    override init()
    {
        
    }
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let price = "price"
        static let stock = "stock"
        static let UPC = "UPC"
    }
    
    //    //MARK: Initialization
    
    init?(name: String, photo: UIImage, price: String, stock: String, UPC: String){
        
        self.name = name
        self.photo = photo
        self.price = price
        self.stock = stock
        self.UPC = UPC
    }

    
    //encodes the element of an item to be archived and saved
    
        func encode(with aCoder: NSCoder) {
            aCoder.encode(name, forKey: PropertyKey.name)
            aCoder.encode(photo, forKey: PropertyKey.photo)
            aCoder.encode(price, forKey: PropertyKey.price)
            aCoder.encode(stock, forKey: PropertyKey.stock)
            aCoder.encode(UPC, forKey: PropertyKey.UPC)
        }
    
    //decodes the element of an item to load the items if the application is closed and reopened
    
        required convenience init?(coder aDecoder: NSCoder) {
    
            // The name is required. If we cannot decode a name string, the initializer should fail.
            let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
            var photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
            let price = aDecoder.decodeObject(forKey: PropertyKey.price) as? String
            let stock = aDecoder.decodeObject(forKey: PropertyKey.stock) as? String
            let UPC = aDecoder.decodeObject(forKey: PropertyKey.UPC) as? String
            
            let data = UPC?.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 3, y: 3)
                
                if let output = filter.outputImage?.applying(transform) {
                    photo = UIImage(ciImage: output)
                    
                }
                
                //}
            }
            
    
            // Must call designated initializer.
            self.init(name: name!, photo: photo!, price: price!, stock: stock!, UPC: UPC!)
            
        }
}





