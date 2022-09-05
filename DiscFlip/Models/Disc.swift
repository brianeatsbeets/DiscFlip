//
//  Disc.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// This class represents a disc to be sold
class Disc: Codable, CustomStringConvertible {
    
    var name: String
    var plastic: String
    var purchasePrice: Int
    var estSellPrice: Int
    var soldPrice: Int
    
    // Property required by CustomStringConvertible protocol
    var description: String
    
    init(name: String, plastic: String, purchasePrice: Int, estSellPrice: Int, soldPrice: Int = 0) {
        self.name = name
        self.plastic = plastic
        self.purchasePrice = purchasePrice
        self.estSellPrice = estSellPrice
        self.soldPrice = soldPrice
        
        self.description = plastic + " " + name
    }
}
