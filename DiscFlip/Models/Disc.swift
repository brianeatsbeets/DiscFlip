//
//  Disc.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// This class represents a disc to be sold
class Disc: Codable {
    
    var name: String
    var plastic: String
    var purchasePrice: Int
    var estSellPrice: Int
    var soldPrice: Int
    
    init(name: String, plastic: String, purchasePrice: Int, estSellPrice: Int, soldPrice: Int = 0) {
        self.name = name
        self.plastic = plastic
        self.purchasePrice = purchasePrice
        self.estSellPrice = estSellPrice
        self.soldPrice = soldPrice
    }
}
