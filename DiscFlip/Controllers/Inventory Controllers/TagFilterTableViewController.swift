//
//  TagFilterTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/28/22.
//

// TODO: Maybe use prototype cell instead of xib
// TODO: Use initializer?

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view controller displays the tag filter options
class TagFilterTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    weak var delegate: TagFilterDelegate?
    var allTags = [Tag]()
    var activeTagFilters = [Tag]()
    private lazy var dataSource = createDataSource()
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TagFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "TagFilterCell")
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
        var i = 0
        
        while i < tableView.numberOfRows(inSection: 0) {
            guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: i, section: 0)) else { return }
            if activeTagFilters.firstIndex(of: tagForRow) != nil {
                tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
            }
            i += 1
        }
    }

    // MARK: - Table view data source
    
    // Define what to do when a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Add the selected tag to the list of tags to filter on
        guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
        activeTagFilters.append(tagForRow)
        
        delegate?.filterInventory(tagFilters: activeTagFilters)
        dismiss(animated: true)
    }
    
    // Define what to do when a cell is deselected
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // Remove the selected tag from the list of tags to filter on
        guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
        if let index = activeTagFilters.firstIndex(of: tagForRow) {
            activeTagFilters.remove(at: index)
        }
        
        delegate?.filterInventory(tagFilters: activeTagFilters)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TagFilterTableViewCell
            
            cell.tagFilterCellLabel.text = tag.title
            
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
