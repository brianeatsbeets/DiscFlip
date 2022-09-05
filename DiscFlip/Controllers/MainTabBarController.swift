//
//  MainTabBarController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/3/22.
//

// TODO: Validate inventory load before view controllers fetch data

import UIKit

// This protocol allows the inventory to be accessed and updated by other views
protocol InventoryDelegate: AnyObject {
    func updateInventory(newInventory: [Disc])
    func checkoutInventory() -> [Disc]
}

// This class acts as the inventory delegate data source and fetches the initial data
class MainTabBarController: UITabBarController {
    
    var inventory = [Disc]()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchInventory()
        setDelegates()
    }
    
    // Fetch the existing disc inventory
    func fetchInventory() {
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("inventory") . appendingPathExtension("plist")
        
        // Fetch and decode data
        let propertyListDecoder = PropertyListDecoder()
        if let inventoryData = try? Data(contentsOf: archiveURL),
           let decodedInventory = try? propertyListDecoder.decode([Disc].self, from: inventoryData) {
            inventory = decodedInventory
        }
        
        print("Fetched inventory from data source: \(inventory)")
    }
    
    // Set the delegate of each child view controller to self
    func setDelegates() {
        let dashboardNavigationController = viewControllers?[0] as! UINavigationController
        let dashboardViewController = dashboardNavigationController.viewControllers.first as! DashboardViewController
        dashboardViewController.delegate = self
        
        let inventoryNavigationController = viewControllers?[1] as! UINavigationController
        let inventoryTableViewController = inventoryNavigationController.viewControllers.first as! InventoryTableViewController
        inventoryTableViewController.delegate = self
    }
}

// This extension of MainTabBarController conforms to the InventoryDelegate protocol
extension MainTabBarController: InventoryDelegate {
    func updateInventory(newInventory: [Disc]) {
        inventory = newInventory
    }
    
    func checkoutInventory() -> [Disc] {
        return inventory
    }
}
