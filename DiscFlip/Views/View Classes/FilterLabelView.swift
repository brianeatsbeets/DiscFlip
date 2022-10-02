//
//  FilterLabelView.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 10/2/22.
//

import UIKit

class FilterLabelView: UIView {
    
    var filter: InventoryFilter
    weak var delegate: RemoveInventoryFilterDelegate?
    
    @IBOutlet var removeFilterButton: UIButton!
    @IBOutlet var filterLabel: UILabel!
    
    init(filter: InventoryFilter) {
        self.filter = filter
        // Can this be any arbitraty frame?
        super.init(frame: CGRect(x: 0, y: 0, width: 63, height: 22))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func removeFilterButtonPressed() {
        delegate?.removeFilter(filter: filter, filterView: self)
    }
}
