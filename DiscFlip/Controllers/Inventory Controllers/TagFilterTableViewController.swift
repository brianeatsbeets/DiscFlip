//
//  TagFilterTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/28/22.
//

// TODO: Maybe use prototype cell instead of xib
// TODO: Use initializer

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view controller displays the inventory filter options
class TagFilterTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    weak var delegate: TagFilterDelegate?
    var allTags = [Tag]()
    var activeStandardFilter = InventoryFilter.all
    var activeTagFilters = [Tag]()
    private lazy var dataSource = createDataSource()
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "InventoryFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "TagFilterCell")
        tableView.dataSource = dataSource
        
        updateTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSelectedFilterRow()
    }
    
    // MARK: - Utility functions
    
    // Pre-select the row for the current filter setting
    func setSelectedFilterRow() {
//        for (index, _) in activeTagFilters.enumerated() {
//            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
//        }
        
        var i = 0
        
        while i < tableView.numberOfRows(inSection: 0) {
            guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: i, section: 0)) else { return }
            if activeTagFilters.firstIndex(of: tagForRow) != nil {
                tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
                print("Pre-selected row \(i)")
            }
            i += 1
        }
    }

    // MARK: - Table view data source
    
    // Determine if the cell should be able to be selected
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//
//        // Only allow cell selection if it isn't already selected
//        if let cell = tableView.cellForRow(at: indexPath), cell.isSelected {
//            return nil
//        }
//        else {
//            return indexPath
//        }
//    }
    
    // Determine if the cell should be able to be highlighted
//    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//
//        // Only allow cell to be highlighted if it isn't already selected
//        if let cell = tableView.cellForRow(at: indexPath), cell.isSelected {
//            return false
//        }
//        else {
//            return true
//        }
//    }
    
    // Define what to do when a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
        activeTagFilters.append(tagForRow)

        delegate?.filterInventory(standardFilter: activeStandardFilter, tagFilters: activeTagFilters)
        dismiss(animated: true)
    }
    
    // Define what to do when a cell is deselected
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
        if let index = activeTagFilters.firstIndex(of: tagForRow) {
            activeTagFilters.remove(at: index)
            print("Deselected row")
        }

        delegate?.filterInventory(standardFilter: activeStandardFilter, tagFilters: activeTagFilters)
        dismiss(animated: true)
    }
}

// MARK: - Extensions

// This extention houses table view management functions using the diffable data source API and conforms to the RemoveCashDelegate protocol
extension TagFilterTableViewController {
    
    // Create the the data source and specify what to do with a provided cell
    private func createDataSource() -> UITableViewDiffableDataSource<Section, Tag> {
        
        // Create a locally-scoped copy of cellReuseIdentifier to avoid referencing self in closure below
        let reuseIdentifier = "TagFilterCell"
        
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, tag in
            // Configure the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InventoryFilterTableViewCell
            
            cell.inventoryFilterCellLabel.text = tag.title
            
            return cell
        }
    }
    
    // Apply a snapshot with updated cash data
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Tag>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(allTags)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Enums

// This enum declares table view sections
private enum Section: CaseIterable {
    case one
}

// This enum defines the inventory filter options
enum InventoryFilter: String {
    case all = "All Discs"
    case unsold = "Unsold Discs"
    case soldAll = "Sold Discs (all)"
    case soldOnEbay = "Sold Discs (on eBay)"
    case soldNotOnEbay = "Sold Discs (outside eBay)"
}
