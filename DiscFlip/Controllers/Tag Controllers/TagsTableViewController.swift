//
//  TagsTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 10/5/22.
//

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
    let cellReuseIdentifier = "tagCell"
    private lazy var dataSource = createDataSource()
    weak var delegate: DataDelegate?
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTags()
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = 44
        
        updateTableView()
    }
    
    // MARK: - Utility functions
    
    // Fetch the tags
    func loadTags() {
        if let initialTags = delegate?.checkoutTags() {
            tags = initialTags
            print("Loaded tags")
        } else {
            print("Failed to fetch initial tags from DashboardViewController")
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            let tagTitleTextField = UITextField()
            tagTitleTextField.textColor = .white
            tagTitleTextField.tintColor = .white
            tagTitleTextField.font = UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)
            tagTitleTextField.textAlignment = .center
            tagTitleTextField.placeholder = "Tag Name"
            tagTitleTextField.borderStyle = .none
            tagTitleTextField.adjustsFontSizeToFitWidth = true
            tagTitleTextField.minimumFontSize = 10
            tagTitleTextField.autocapitalizationType = .words
            tagTitleTextField.translatesAutoresizingMaskIntoConstraints = false
            
            tagTitleTextField.text = tag.title
            
            cell.addSubview(tagTitleTextField)
            
            tagTitleTextField.topAnchor.constraint(equalTo: cell.topAnchor, constant: 4.5).isActive = true
            tagTitleTextField.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
            tagTitleTextField.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 20).isActive = true
            tagTitleTextField.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
            
            print("Created cell: \(tag)")
            
            return cell
        }
    }
    
    // Apply a snapshot with updated tag data
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Tag>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(tags)
        dataSource.apply(snapshot, animatingDifferences: true)
        print("Updated table view")
    }
    
    // Apply a snapshot with removed tag data
    func remove(tag: Tag) {
        
        // Remove tag from tags array
        tags = tags.filter { $0 != tag }
        
        // Remove tag from the snapshot and apply it
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([tag])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        // Save the tags array to file
        //Cash.saveCash(cashList)
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
