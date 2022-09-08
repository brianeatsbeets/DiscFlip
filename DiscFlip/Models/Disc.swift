//
//  Disc.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// This class represents a disc to be sold
struct Disc: Codable, CustomStringConvertible {
    
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
        self.name = name
        self.plastic = plastic
        self.purchasePrice = purchasePrice
        self.estSellPrice = estSellPrice
        self.soldPrice = soldPrice
        self.soldOnEbay = soldOnEbay
        self.eBayProfit = soldPrice - purchasePrice > 0 ? soldPrice - purchasePrice : 0
        
        self.description = plastic + " " + name
    }
}
