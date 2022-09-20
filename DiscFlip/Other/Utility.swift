//
//  Utility.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/12/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Extensions

// This Int extension returns the Int as a string with proper currency/polarity formatting, i.e. "-$" instead of "$-"
extension Int {
    func currencyWithPolarity() -> String {
        self >= 0 ? "$\(self)" : "-$\(-self)"
    }
}
