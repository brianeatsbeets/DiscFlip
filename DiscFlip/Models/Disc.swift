//
//  Disc.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// MARK: - Imported libraries

import Foundation

// MARK: - Main class

// This class represents a disc to be sold
struct Disc: Codable, CustomStringConvertible, Hashable {
    
    // MARK: - Class properties
    
    let id: UUID
    var name: String
    var plastic: String
    var purchasePrice: Int
    var estSellPrice: Int
    var wasSold: Bool
    var soldPrice: Int
    var tags: [Tag]
    
    // Property required by CustomStringConvertible protocol
    var description: String
    
    // MARK: - Initializers
    
    init(name: String, plastic: String, purchasePrice: Int, estSellPrice: Int = 0, wasSold: Bool, soldPrice: Int = 0, tags: [Tag] = [Tag]()) {
        self.id = UUID()
        self.name = name
        self.plastic = plastic
        self.purchasePrice = purchasePrice
        self.estSellPrice = estSellPrice
        self.wasSold = wasSold
        self.soldPrice = soldPrice
        self.tags = tags
        
        self.description = plastic + " " + name
    }
    
    // MARK: - Utility functions
    
    // Save the updated inventory
    static func saveInventoryToDisk(_ inventory: [Disc]) {
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("inventory") . appendingPathExtension("plist")
        
        // Encode data
        let propertyListEncoder = PropertyListEncoder()
        if let encodedInventory = try? propertyListEncoder.encode(inventory) {
            // Save inventory
            try? encodedInventory.write(to: archiveURL, options: .noFileProtection)
        }
    }
}
