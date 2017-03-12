//
//  JSONReader.swift
//  CoreDataPractice
//
//  Created by Jayesh Kawli on 3/12/17.
//  Copyright © 2017 Jayesh Kawli. All rights reserved.
//

import Foundation

class JSONReader {
    static func readJSONFromFileWith(name: String) -> AnyObject? {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                    return json
                } catch let error as NSError {
                    print("Failed to convert JSON data into container. Failed with error \(error.localizedDescription)")
                }
            } catch let error as NSError {
                print("Failed to read json from file. Failed with error \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename or path \(name)")
        }
        return nil
    }
}
