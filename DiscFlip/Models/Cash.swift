//
//  Cash.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/6/22.
//

import Foundation

// This class represents cash funds added to the overall total
struct Cash: Codable, CustomStringConvertible, Hashable {

    let id: UUID
    var amount: Int
    var memo: String
    
    // Property required by CustomStringConvertible protocol
    var description: String
    
    init(amount: Int, memo: String) {
        self.id = UUID()
        self.amount = amount
        self.memo = memo
        self.description = "$\(amount): \(memo)"
    }
    
    // Save the updated cash
    static func saveCash(_ cashList: [Cash]) {
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("cash") . appendingPathExtension("plist")
        
        // Encode data
        let propertyListEncoder = PropertyListEncoder()
        if let encodedCash = try? propertyListEncoder.encode(cashList) {
            // Save cash
            try? encodedCash.write(to: archiveURL, options: .noFileProtection)
        }
        
        print("Saved inventory to data source: \(cashList)")
    }
}
