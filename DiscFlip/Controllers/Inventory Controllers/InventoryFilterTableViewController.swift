//
//  InventoryFilterTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/28/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view controller displays the inventory filter options
class InventoryFilterTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    weak var delegate: InventoryFilterDelegate?
    var selectedFilter = InventoryFilter.all
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "InventoryFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "InventoryFilterCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSelectedFilterRow()
    }
    
    // MARK: - Utility functions
    
    // Pre-select the row for the current filter setting
    func setSelectedFilterRow() {
        var indexPath: IndexPath
        
        switch selectedFilter {
        case .unsold:
            indexPath = IndexPath(row: 1, section: 0)
        case .soldAll:
            indexPath = IndexPath(row: 2, section: 0)
        case .soldOnEbay:
            indexPath = IndexPath(row: 3, section: 0)
        case .soldNotOnEbay:
            indexPath = IndexPath(row: 4, section: 0)
        default:
            indexPath = IndexPath(row: 0, section: 0)
        }
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryFilterCell", for: indexPath) as! InventoryFilterTableViewCell
        
        switch indexPath.row {
        case 1:
            cell.inventoryFilterCellLabel.text = InventoryFilter.unsold.rawValue
        case 2:
            cell.inventoryFilterCellLabel.text = InventoryFilter.soldAll.rawValue
        case 3:
            cell.inventoryFilterCellLabel.text = InventoryFilter.soldOnEbay.rawValue
        case 4:
            cell.inventoryFilterCellLabel.text = InventoryFilter.soldNotOnEbay.rawValue
        default:
            cell.inventoryFilterCellLabel.text = InventoryFilter.all.rawValue
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            selectedFilter = .unsold
        case 2:
            selectedFilter = .soldAll
        case 3:
            selectedFilter = .soldOnEbay
        case 4:
            selectedFilter = .soldNotOnEbay
        default:
            selectedFilter = .all
        }
        
        delegate?.filterInventory(filter: selectedFilter, resetButtonTapped: false)
        dismiss(animated: true)
    }
}

// MARK: - Enums

// This enum defines the inventory filter options
enum InventoryFilter: String {
    case all = "All Discs"
    case unsold = "Unsold Discs"
    case soldAll = "Sold Discs (all)"
    case soldOnEbay = "Sold Discs (on eBay)"
    case soldNotOnEbay = "Sold Discs (outside eBay)"
}
