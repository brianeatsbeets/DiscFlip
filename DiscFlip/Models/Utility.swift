//
//  Utility.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/12/22.
//

import UIKit

// This Int extension returns the Int as a string with proper currency/polarity formatting, i.e. "-$" instead of "$-"
extension Int {
    func currencyWithPolarity() -> String {
        self >= 0 ? "$\(self)" : "-$\(-self)"
    }
}
