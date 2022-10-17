//
//  TagsTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 10/5/22.
//

// TODO: When deleting a tag, remove it from the active tag filters on the inventory table view controller if applicable
// TODO: Fix constraing warning

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// This protocol allows conformers to remove tags
protocol RemoveTagDelegate: AnyObject {
    func remove(tag: Tag)
}

// MARK: - Main class

// This class/table view controller displays tags that have been added
class TagsTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    var tags = [Tag]()
    var inventory = [Disc]()
    let cellReuseIdentifier = "tagCell"
    private lazy var dataSource = createDataSource()
    weak var delegate: DataDelegate?
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTags()
        loadInventory()
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
        
        updateTableView(animated: false)
    }
    
    // MARK: - Utility functions
    
    // Fetch the tags
    func loadTags() {
        if let initialTags = delegate?.checkoutTags() {
            tags = initialTags
        } else {
            print("Failed to fetch initial tags from DashboardViewController")
        }
    }
    
    // Fetch the inventory
    func loadInventory() {
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
    }
    
    // Create a new empty cell and begin editing
    @IBAction func addButtonPressed(_ sender: Any) {
        tags.append(Tag(title: ""))
        updateTableView()
        
        let cell = tableView.cellForRow(at: IndexPath(row: tags.count - 1, section: 0)) as! TagsTableViewCell
        cell.tagTitleTextField.becomeFirstResponder()
    }
    
    // Save/Update the tag being edited when the done key is pressed (if the title was actually updated)
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guard let newTitle = sender.text,
              let cell = sender.superview?.superview as? TagsTableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        if !newTitle.isEmpty {
            updateTag(at: indexPath.row, with: newTitle)
        } else {
            tags.remove(at: tags.count - 1)
            updateTableView()
        }
        
        sender.resignFirstResponder()
    }
    
    func updateTag(at row: Int, with newTitle: String) {
        
        // Make sure the tags array contains the provided index
        guard tags.indices.contains(row) else { return }
        
        tags[row].title = newTitle
        updateTableView(animated: false)
        
        delegate?.updateTags(newTagsList: tags)
        Tag.saveTagsToDisk(tags)
    }
    
}

// MARK: - Extensions

// This extention houses table view management functions using the diffable data source API and conforms to the RemoveTagDelegate protocol
extension TagsTableViewController: RemoveTagDelegate {
    
    // Create the the data source and specify what to do with a provided cell
    private func createDataSource() -> DeletableRowTableViewDiffableDataSource {
        
        // Create a locally-scoped copy of cellReuseIdentifier to avoid referencing self in closure below
        let reuseIdentifier = cellReuseIdentifier
        
        return DeletableRowTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, tag in
            // Configure the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TagsTableViewCell
            
            cell.tagTitleTextField.text = tag.title
            
            return cell
        }
    }
    
    // Apply a snapshot with updated tag data
    func updateTableView(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Tag>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(tags)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // Apply a snapshot with removed tag data
    func remove(tag: Tag) {
        
        // Remove tag from tags array
        tags = tags.filter { $0 != tag }
        
        // Remove tag from any discs that have it
        for index in 0..<inventory.count {
            inventory[index].tags = inventory[index].tags.filter { $0 != tag }
        }
        
        // Remove tag from the snapshot and apply it
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([tag])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        delegate?.updateTags(newTagsList: tags)
        
        Tag.saveTagsToDisk(tags)
    }
}

// MARK: - Enums

// This enum declares table view sections
private enum Section: CaseIterable {
    case one
}

// MARK: - Other classes

// This class defines a UITableViewDiffableDataSource subclass that enables swipe-to-delete
private class DeletableRowTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Tag> {
    
    // MARK: - Class properties
    
    // Delegate to update data model
    weak var delegate: RemoveTagDelegate?
    
    // MARK: - Utility functions
    
    // Allow the table view to be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Allow table view rows to be deleted
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let tagToDelete = itemIdentifier(for: indexPath) {
            delegate?.remove(tag: tagToDelete)
        }
    }
}
