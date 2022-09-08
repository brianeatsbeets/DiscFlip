//
//  Cash.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/6/22.
//

// This class represents cash funds added to the overall total
struct Cash: Codable, CustomStringConvertible {

    var amount: Int
    var memo: String
    
    // Property required by CustomStringConvertible protocol
    var description: String
    
    init(amount: Int, memo: String) {
        self.amount = amount
        self.memo = memo
        self.description = "$\(amount): \(memo)"
    }
}
