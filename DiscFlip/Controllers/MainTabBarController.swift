//
//  MainTabBarController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/3/22.
//

// TODO: Validate inventory load before view controllers fetch data

import UIKit

// This protocol allows the inventory and cash to be accessed and updated by other views
protocol DataDelegate: AnyObject {
    func updateInventory(newInventory: [Disc])
    func checkoutInventory() -> [Disc]
    func updateCash(newCash: [Cash])
    func checkoutCash() -> [Cash]
}

// This class acts as the inventory delegate data source and fetches the initial data
class MainTabBarController: UITabBarController {
    
    var inventory = [Disc]()
    var cash = [Cash]()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        setDelegates()
    }
    
    // Fetch the existing disc inventory and cash
    func fetchData() {
        
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Initialize property list decoder
        let propertyListDecoder = PropertyListDecoder()
        
        // Ser archive URL to inventory path
        var archiveURL = documentsDirectory.appendingPathComponent("inventory") . appendingPathExtension("plist")
        
        // Fetch and decode inventorydata
        if let inventoryData = try? Data(contentsOf: archiveURL),
           let decodedInventory = try? propertyListDecoder.decode([Disc].self, from: inventoryData) {
            inventory = decodedInventory
        }
        
        print("Fetched inventory from data source: \(inventory)")
        
        // Update archiveURL for cash path
        archiveURL = documentsDirectory.appendingPathComponent("cash") . appendingPathExtension("plist")
        
        // Fetch and decode data
        if let cashData = try? Data(contentsOf: archiveURL),
           let decodedCash = try? propertyListDecoder.decode([Cash].self, from: cashData) {
            cash = decodedCash
        }
        
        print("Fetched cash from data source: \(cash)")
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

// This extension of MainTabBarController conforms to the DataDelegate protocol
extension MainTabBarController: DataDelegate {
    func updateInventory(newInventory: [Disc]) {
        inventory = newInventory
    }
    
    func checkoutInventory() -> [Disc] {
        return inventory
    }
    
    func updateCash(newCash: [Cash]) {
        cash = newCash
    }
    
    func checkoutCash() -> [Cash] {
        return cash
    }
}
