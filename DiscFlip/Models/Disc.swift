//
//  Disc.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// This class represents a disc to be sold
class Disc: Item {
    
    var plastic: String
    
    init(name: String, purchasePrice: Int, estSellPrice: Int = 0, soldPrice: Int = 0, plastic: String) {
        self.plastic = plastic
        super.init(name: name, purchasePrice: purchasePrice, estSellPrice: estSellPrice, soldPrice: soldPrice)
    }
}
