//
//  TagFilterTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/28/22.
//

// TODO: Maybe use prototype cell instead of xib
// TODO: Rename this class via Refactor

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view controller displays the tag filter options
class TagFilterTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    var context: TagSelectNavigationContext
    weak var delegate: TagFilterDelegate? // Not needed once instantiated via IBSegueAction
    var allTags: [Tag]
    var selectedTags: [Tag]
    private lazy var dataSource = createDataSource()
    
    // MARK: - Initializers
    
    // Initialize from AddEditDiscTableViewController
    init?(coder: NSCoder, allTags: [Tag], currentTags: [Tag]) {
        self.allTags = allTags
        self.selectedTags = currentTags
        self.context = .addEditDisc
        super.init(coder: coder)
    }
    
    // Initialize from InventoryFilterTableViewController
    init?(coder: NSCoder, allTags: [Tag], activeTagFilters: [Tag]) {
        self.allTags = allTags
        self.selectedTags = activeTagFilters
        self.context = .inventoryFilter
        super.init(coder: coder)
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        // Select rows for inventory tag filters
        if context == .inventoryFilter {
            var i = 0
            while i < tableView.numberOfRows(inSection: 0) {
                guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: i, section: 0)) else { return }
                if selectedTags.firstIndex(of: tagForRow) != nil {
                    tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
                }
                i += 1
            }
        } else {
            // Select rows for assigning tags to disc
            var i = 0
            while i < tableView.numberOfRows(inSection: 0) {
                guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: i, section: 0)) else { return }
                if selectedTags.firstIndex(of: tagForRow) != nil {
                    tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
                }
                i += 1
            }
        }
    }

    // MARK: - Table view data source
    
    // Define what to do when a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Action for inventory tag filters
        if context == .inventoryFilter {
            guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
            
            // Add the selected tag to the list of tags to filter on
            selectedTags.append(tagForRow)
            
            delegate?.filterInventory(tagFilters: selectedTags)
            dismiss(animated: true)
        } else {
            // Action for assigning tags to disc
            guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
            
            // Add the selected tag to the list of tags associated with the disc
            selectedTags.append(tagForRow)
        }
    }
    
    // Define what to do when a cell is deselected
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // Action for inventory tag filters
        if context == .inventoryFilter {
            guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
            
            // Remove the selected tag from the list of tags to filter on
            if let index = selectedTags.firstIndex(of: tagForRow) {
                selectedTags.remove(at: index)
            }
            
            delegate?.filterInventory(tagFilters: selectedTags)
            dismiss(animated: true)
        } else {
            // Action for assigning tags to disc
            guard let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
            
            // Remove the selected tag from the list of tags associated with the disc
            if let index = selectedTags.firstIndex(of: tagForRow) {
                selectedTags.remove(at: index)
            }
        }
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
