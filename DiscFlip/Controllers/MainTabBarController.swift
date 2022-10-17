//
//  MainTabBarController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/3/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// This protocol allows the inventory to be accessed and updated by other views
protocol DataDelegate: AnyObject {
    func updateInventory(newInventory: [Disc])
    func checkoutInventory() -> [Disc]
    func updateTags(newTagsList: [Tag])
    func checkoutTags() -> [Tag]
}

// MARK: - Main class

// This class acts as the inventory delegate data source and fetches the initial data
class MainTabBarController: UITabBarController {
    
    // MARK: - Class properties
    
    var inventory = [Disc]()
    var tags = [Tag]()
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData() // Uncomment to use real data
        //loadDummyData() // Uncomment to use dummy data
        setDelegates()
        stylizeTabBarItems()
    }
    
    // MARK: - Utility functions
    
    // Create and load placeholder data for testing purposes
    func loadDummyData() {
        
        tags = [
            Tag(title: "eBay"),
            Tag(title: "Craigslist"),
            Tag(title: "Unsure about selling"),
            Tag(title: "Trash")
        ]
        
        inventory = [
            Disc(name: "Aviar", plastic: "DX", purchasePrice: 10, estSellPrice: 12, wasSold: false, tags: [tags[2], tags[1]]),
            Disc(name: "Mako3", plastic: "Champion", purchasePrice: 12, estSellPrice: 15, wasSold: false, tags: [tags[2]]),
            Disc(name: "Teebird", plastic: "Star", purchasePrice: 14, estSellPrice: 18, wasSold: false, tags: [tags[2]]),
            Disc(name: "Leopard3", plastic: "GStar", purchasePrice: 13, estSellPrice: 16, wasSold: false, tags: [tags[1]]),
            Disc(name: "Thunderbird", plastic: "Champion", purchasePrice: 16, estSellPrice: 22, wasSold: false),
            Disc(name: "Savant", plastic: "Halo", purchasePrice: 16, estSellPrice: 22, wasSold: true, soldPrice: 23, tags: [tags[1]]),
            Disc(name: "Valkyrie", plastic: "Champion", purchasePrice: 16, estSellPrice: 20, wasSold: true, soldPrice: 23),
            Disc(name: "Wraith", plastic: "Star Color Glow", purchasePrice: 18, estSellPrice: 22, wasSold: true, soldPrice: 25, tags: [tags[0]]),
            Disc(name: "Destroyer", plastic: "Pro", purchasePrice: 14, estSellPrice: 18, wasSold: true, soldPrice: 18, tags: [tags[0]]),
            Disc(name: "Katana", plastic: "GStar", purchasePrice: 16, estSellPrice: 22, wasSold: true, soldPrice: 23, tags: [tags[0]])
        ]
    }
    
    // Fetch the existing disc inventory
    func fetchData() {
        
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Initialize property list decoder
        let propertyListDecoder = PropertyListDecoder()
        
        // Ser archive URL to inventory path
        var archiveURL = documentsDirectory.appendingPathComponent("inventory") . appendingPathExtension("plist")
        
        // Fetch and decode inventory data
        if let inventoryData = try? Data(contentsOf: archiveURL),
           let decodedInventory = try? propertyListDecoder.decode([Disc].self, from: inventoryData) {
            inventory = decodedInventory
        }
        
        // Update archiveURL for tags path
        archiveURL = documentsDirectory.appendingPathComponent("tags") . appendingPathExtension("plist")
        
        // Fetch and decode tag data
        if let tagsData = try? Data(contentsOf: archiveURL),
           let decodedTags = try? propertyListDecoder.decode([Tag].self, from: tagsData) {
            tags = decodedTags
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
        
        let tagsNavigationController = viewControllers?[2] as! UINavigationController
        let tagsTableViewController = tagsNavigationController.viewControllers.first as! TagsTableViewController
        tagsTableViewController.delegate = self
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
    
    // Update the tags list with the provided data
    func updateTags(newTagsList: [Tag]) {
        tags = newTagsList
    }
    
    // Retrieve the saved tags list
    func checkoutTags() -> [Tag] {
        return tags
    }
}
