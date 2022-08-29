//
//  Item.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// This class represents an item to be sold
class Item {
    
    var name: String
    var purchasePrice: Int
    var estSellPrice: Int
    var soldPrice: Int
    
    init(name: String, purchasePrice: Int, estSellPrice: Int = 0, soldPrice: Int = 0) {
        self.name = name
        self.purchasePrice = purchasePrice
        self.estSellPrice = estSellPrice
        self.soldPrice = soldPrice
    }
}
