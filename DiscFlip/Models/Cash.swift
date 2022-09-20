//
//  Cash.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/6/22.
//

// MARK: - Imported libraries

import Foundation

// MARK: - Main class

// This class represents cash funds added to the overall total
struct Cash: Codable, CustomStringConvertible, Hashable {
    
    // MARK: - Class properties

    let id: UUID
    var amount: Int
    var memo: String
    
    // Property required by CustomStringConvertible protocol
    var description: String
    
    // MARK: - Initializers
    
    init(amount: Int, memo: String) {
        self.id = UUID()
        self.amount = amount
        self.memo = memo
        self.description = "$\(amount): \(memo)"
    }
    
    // MARK: - Utility functions
    
    // Save the updated cash
    static func saveCash(_ cashList: [Cash]) {
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("cashList") . appendingPathExtension("plist")
        
        // Encode data
        let propertyListEncoder = PropertyListEncoder()
        if let encodedCash = try? propertyListEncoder.encode(cashList) {
            // Save cash
            try? encodedCash.write(to: archiveURL, options: .noFileProtection)
        }
    }
}
