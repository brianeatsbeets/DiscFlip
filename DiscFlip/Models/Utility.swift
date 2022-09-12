//
//  Utility.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/12/22.
//

import UIKit

// This class/table view cell defines a cell with no separator view/lines
// Referenced from https://stackoverflow.com/questions/49721027/why-isnt-uitableviewcells-separator-view-listed
class NoSeparatorCell: UITableViewCell {
    
    // Remove the UITableViewCellSeparatorView
    // Kind of hacky, but currently no offical way to remove separator lines from only a single cell
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews {
            let description = String(describing: type(of: view))
            if description.hasSuffix("SeparatorView") {
                view.removeFromSuperview()
            }
        }
    }
}
// This UITextField extension provides a function to set a dollar sign prefix
// Adapted from https://stackoverflow.com/questions/28434993/uneditable-prefix-inside-a-uitextfield-using-swift
extension UITextField {
    func setCurrentyPrefix(fontSize: CGFloat) {
        let prefixLabel = UILabel()
        prefixLabel.text = "$"
        prefixLabel.font = prefixLabel.font.withSize(fontSize)
        prefixLabel.sizeToFit()
        
        leftView = prefixLabel
        leftViewMode = .always
    }
}
