//
//  Disc.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

import Foundation

// This class represents a disc to be sold
struct Disc: Codable, CustomStringConvertible, Hashable {
    
    let id: UUID
    var name: String
    var plastic: String
    var purchasePrice: Int
    var estSellPrice: Int
    var soldPrice: Int
    var soldOnEbay: Bool
    var eBayProfit: Int
    
    // Property required by CustomStringConvertible protocol
    var description: String
    
    init(name: String, plastic: String, purchasePrice: Int, estSellPrice: Int, soldPrice: Int = 0, soldOnEbay: Bool) {
        self.id = UUID()
        self.name = name
        self.plastic = plastic
        self.purchasePrice = purchasePrice
        self.estSellPrice = estSellPrice
        self.soldPrice = soldPrice
        self.soldOnEbay = soldOnEbay
        self.eBayProfit = soldPrice - purchasePrice > 0 ? soldPrice - purchasePrice : 0
        
        self.description = plastic + " " + name
    }
    
    // Save the updated inventory
    static func saveInventory(_ inventory: [Disc]) {
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("inventory") . appendingPathExtension("plist")
        
        // Encode data
        let propertyListEncoder = PropertyListEncoder()
        if let encodedInventory = try? propertyListEncoder.encode(inventory) {
            // Save inventory
            try? encodedInventory.write(to: archiveURL, options: .noFileProtection)
        }
        
        print("Saved inventory to data source: \(inventory)")
    }
}
