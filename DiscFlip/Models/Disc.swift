//
//  Disc.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// This class represents a disc to be sold
class Disc {
    
    var name: String
    var plastic: String
    var purchasePrice: Int
    var estSellPrice: Int
    var soldPrice: Int
    
    init(name: String, plastic: String, purchasePrice: Int, estSellPrice: Int = 0, soldPrice: Int = 0) {
        self.name = name
        self.plastic = plastic
        self.purchasePrice = purchasePrice
        self.estSellPrice = estSellPrice
        self.soldPrice = soldPrice
    }
}
