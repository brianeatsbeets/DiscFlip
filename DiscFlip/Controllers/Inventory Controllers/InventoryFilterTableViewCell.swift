//
//  InventoryFilterTableViewCell.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/28/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view cell presents filter options for the inventory
class InventoryFilterTableViewCell: UITableViewCell {
    
    // MARK: - Class properties
    
    @IBOutlet var inventoryFilterCellLabel: UILabel!
    
    // MARK: - View life cycle functions

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Utility functions
    
    // Update the cell UI when the selected state is changed
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectedBackgroundView!.backgroundColor = selected ? .white : backgroundColor!
        inventoryFilterCellLabel.textColor = selected ? .black : .white
    }
    
    // Update the cell UI when the highlighted state is changed
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let cellBackgroundColor = UIColor(red: 68/255, green: 186/255, blue: 99/255, alpha: 1)
        let cellHighlightColor = UIColor(red: 161/255, green: 1, blue: 139/255, alpha: 1)

        selectedBackgroundView!.backgroundColor = highlighted ? cellHighlightColor : (isSelected ? .white : cellBackgroundColor)
        inventoryFilterCellLabel.textColor = highlighted ? (isSelected ? .white : .black) : (isSelected ? .black : .white)
    }
}
