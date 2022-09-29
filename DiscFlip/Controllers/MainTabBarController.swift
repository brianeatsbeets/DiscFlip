//
//  MainTabBarController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/3/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// This protocol allows the inventory and cash to be accessed and updated by other views
protocol DataDelegate: AnyObject {
    func updateInventory(newInventory: [Disc])
    func checkoutInventory() -> [Disc]
    func updateCashList(newCashList: [Cash])
    func checkoutCashList() -> [Cash]
}

// MARK: - Main class

// This class acts as the inventory delegate data source and fetches the initial data
class MainTabBarController: UITabBarController {
    
    // MARK: - Class properties
    
    var inventory = [Disc]()
    var cashList = [Cash]()
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        setDelegates()
        stylizeTabBarItems()
    }
    
    // MARK: - Utility functions
    
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
        
        // Update archiveURL for cash path
        archiveURL = documentsDirectory.appendingPathComponent("cashList") . appendingPathExtension("plist")
        
        // Fetch and decode data
        if let cashData = try? Data(contentsOf: archiveURL),
           let decodedCash = try? propertyListDecoder.decode([Cash].self, from: cashData) {
            cashList = decodedCash
        }
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
    
    // Set tab bar item UI elements
    func stylizeTabBarItems() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 12) ?? .preferredFont(forTextStyle: .body)], for: .normal)
        tabBar.unselectedItemTintColor = UIColor(red: 68/255, green: 168/255, blue: 99/255, alpha: 1)
    }
}

// MARK: - Extensions

// This extension of MainTabBarController conforms to the DataDelegate protocol
extension MainTabBarController: DataDelegate {
    
    // Update the inventory with the provided data
    func updateInventory(newInventory: [Disc]) {
        inventory = newInventory
    }
    
    // Retrieve the saved inventory
    func checkoutInventory() -> [Disc] {
        return inventory
    }
    
    // Update the cash list with the provided data
    func updateCashList(newCashList: [Cash]) {
        cashList = newCashList
    }
    
    // Retrieve the saved cash list
    func checkoutCashList() -> [Cash] {
        return cashList
    }
}
