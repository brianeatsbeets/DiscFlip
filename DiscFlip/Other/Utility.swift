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

// This class creates a button that will be added to each filter view in the filter stack view. The tappable area of this button is larger than the button's actual size.
// Courtesy of Syed Sadrul Ullah Sahad from https://stackoverflow.com/questions/31056703/how-can-i-increase-the-tap-area-for-uibutton
// TODO: Need to troubleshoot this to work outside parent view bounds
class RemoveFilterButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -17, dy: -17).contains(point)
    }
}
