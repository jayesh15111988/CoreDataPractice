//
//  ProductsFetcher.swift
//  CoreDataPractice
//
//  Created by Jayesh Kawli on 3/12/17.
//  Copyright © 2017 Jayesh Kawli. All rights reserved.
//

import UIKit
import Mantle
// An adapter which acts as a bridge between Mantle and Core Data.
import MTLManagedObjectAdapter

enum ProductStorageIndicatorKey: String {
    case ProductStored
}

class ProductsFetcher: NSObject {
    // We will fetch the list of products with given category identifier.
    func fetchProducts() -> [Product] {
        // For the sake of this example project, we will read the data from local JSON file.        
        if let products = JSONReader.readJSONFromFileWith("Products") as? [String: AnyObject] {
            if let listOfProducts = products["products"] as? [[String: AnyObject]] {
                do {
                    // First off, convert JSON dictionaries into Mantle model objects.
                    if let productsCollection = try MTLJSONAdapter.modelsOfClass(Product.self, fromJSONArray: listOfProducts) as? [Product] {
                        // Take Mantle objects as an input and store it into Core data as NSManagedObject models.
                        return self.objectsStoredToDatabaseWithProducts(productsCollection)
                    }
                } catch let error as NSError {
                    print("Failed to fetch and create models from products from local JSON resource. Failed with error \(error.localizedDescription)")
                }
            }
        }
        return []
    }

    func objectsStoredToDatabaseWithProducts(products: [Product]) -> [Product] {

        // This is a shared ManagedObjectContext taken directly from AppDelegate. Instead of using it as a global variable, you might want to do dependency injection.
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let managedContext = appDelegate!.managedObjectContext

        for product in products {
            do {
                // Conversion from Mantle to Core Data realm.
                try MTLManagedObjectAdapter.managedObjectFromModel(product, insertingIntoContext: managedContext)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        do {
            // Save the managedobject context for persistence.
            try managedContext.save()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: ProductStorageIndicatorKey.ProductStored.rawValue)
        } catch let error as  NSError {
            print("Error in saving the managed context \(error.localizedDescription)")
        }
        return self.fetchProductsWith("")
    }

    // We will take catgory identifier as an input and output all products matching with that category identifier.
    func fetchProductsWith(categoryIdentifier: String) -> [Product] {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let managedContext = appDelegate!.managedObjectContext
        // Specify the entity name which records will be extracted from.
        let fetchRequest   = NSFetchRequest(entityName: "Product")
        // Predicate to output only those products matching input categoryIdentifier.
        if categoryIdentifier.characters.count > 0 {
            let predicate = NSPredicate(format: "categoryIdentifier == %@", categoryIdentifier)
            fetchRequest.predicate = predicate
        }

        do {
            let fetchedResult = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]

            var records: [NSManagedObject] = []
            if let results = fetchedResult {
                records = results
            }


            var tempProducts: [Product] = []

            // Convert Core data models into Mantle counterparts.
            for record in records {
                do {
                    if let productModel = try MTLManagedObjectAdapter.modelOfClass(Product.self, fromManagedObject: record) as? Product {
                        tempProducts.append(productModel)
                    }
                } catch let error as NSError {
                    print("Failed to convert NSManagedobject to Model Object. Failed with error \(error.localizedDescription)")
                }
            }
            return tempProducts
        } catch let error as NSError {
            print("Error occurred while fetching products with category identifier \(categoryIdentifier). Failed with error \(error.localizedDescription)")

        }
        // Return an empty array in case error occurs while retriving records.
        return []
    }
}
