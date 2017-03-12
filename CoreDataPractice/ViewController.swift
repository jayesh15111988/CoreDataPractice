//
//  ViewController.swift
//  CoreDataPractice
//
//  Created by Jayesh Kawli on 3/12/17.
//  Copyright © 2017 Jayesh Kawli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

override func viewDidLoad() {
    super.viewDidLoad()
    // Load the data either from file or Core database storage.
    loadData()
}

func loadData() {
    let productsFetcher = ProductsFetcher()
    var products: [Product] = []
    // Check if data has already been stored in the database. If yes, retrieve the specific record
    if NSUserDefaults.standardUserDefaults().boolForKey(ProductStorageIndicatorKey.ProductStored.rawValue) == true {
        products = productsFetcher.fetchProductsWith("1299")
    } else {
        // If data is not present, read if from the file.
        products = productsFetcher.fetchProducts()
    }
    // Print the Debug information.
    print("Products Count \(products.count)")
    print(products)
}
}

