//
//  InventoryFilterTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/26/22.
//

import UIKit

protocol InventoryFilterDelegate: AnyObject {
    func applyFilters(soldDisc: SoldDiscFilter, soldOnEbay: SoldOnEbayFilter)
}

class InventoryFilterTableViewController: UITableViewController {
    
    var delegate: InventoryFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}
