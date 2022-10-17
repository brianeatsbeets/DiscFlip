//
//  SelectTagTableViewController.swift
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
class SelectTagTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    var context: TagSelectNavigationContext
    weak var delegate: TagFilterDelegate?
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
    init?(coder: NSCoder, allTags: [Tag], activeTagFilters: [Tag], delegate: TagFilterDelegate?) {
        self.allTags = allTags
        self.selectedTags = activeTagFilters
        self.context = .inventoryFilter
        self.delegate = delegate
        super.init(coder: coder)
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = (context == .inventoryFilter) ? "Select Tag Filters" : "Select Tags"
        
        tableView.dataSource = dataSource
        updateTableView()
    }
    
    // MARK: - Navigation
    
    // Unwind to the appropriate view controller with the save segue
    @IBAction func saveButtonPressed(_ sender: Any) {
        if context == .inventoryFilter {
            dismiss(animated: true) {
                if self.context == .inventoryFilter {
                    self.delegate?.filterInventory(tagFilters: self.selectedTags)
                }
            }
        } else {
            performSegue(withIdentifier: "saveUnwindToAddEditDisc", sender: self)
        }
    }
    
    // Unwind to the appropriate view controller with the cancel segue
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if context == .inventoryFilter {
            performSegue(withIdentifier: "cancelUnwindToInventoryFromTagFilters", sender: self)
        } else {
            performSegue(withIdentifier: "cancelUnwindToAddEditDisc", sender: self)
        }
    }

    // MARK: - Table view data source
    
    // Define what to do when a cell is will be displayed
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard let cell = cell as? SelectTagTableViewCell,
              let tagForRow = dataSource.itemIdentifier(for: indexPath) else { return }

        // Pre-select the row for the current tag filters/assigned tags
        if selectedTags.firstIndex(of: tagForRow) != nil {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)

            let cellBackgroundView = UIView()
            cellBackgroundView.backgroundColor = cell.isSelected ? .white : cell.backgroundColor!
            cell.selectedBackgroundView = cellBackgroundView

            cell.tagTitleLabel.textColor = cell.isSelected ? .black : .white
        }
    }
    
    // Define what to do when a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SelectTagTableViewCell,
              let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
        
        // Add the selected tag to the list of tags to filter on/the list of tags associated with the disc
        selectedTags.append(tagForRow)
        
        // Stylize cell
        cell.selectedBackgroundView!.backgroundColor = cell.isSelected ? .white : cell.backgroundColor!
        cell.tagTitleLabel.textColor = cell.isSelected ? .black : .white
    }
    
    // Define what to do when a cell is deselected
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SelectTagTableViewCell,
              let tagForRow = dataSource.itemIdentifier(for: IndexPath(row: indexPath.row, section: 0)) else { return }
        
        // Remove the selected tag from the list of tags to filter on/the list of tags associated with the disc
        if let index = selectedTags.firstIndex(of: tagForRow) {
            selectedTags.remove(at: index)
        }
        
        // Stylize cell
        cell.selectedBackgroundView!.backgroundColor = cell.isSelected ? cell.backgroundColor! : .white
        cell.tagTitleLabel.textColor = cell.isSelected ? .black : .white
    }
    
    // Define what to do when a cell is highlighted
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SelectTagTableViewCell else { return }
        
        let cellHighlightColor = UIColor(red: 161/255, green: 1, blue: 139/255, alpha: 1)
        
        // Set the background and text colors
        cell.selectedBackgroundView!.backgroundColor = cellHighlightColor
        cell.tagTitleLabel.textColor = .black
    }
    
    // Define what to do when a cell is unhighlighted
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SelectTagTableViewCell else { return }
        
        let cellBackgroundColor = UIColor(red: 68/255, green: 186/255, blue: 99/255, alpha: 1)
        
        // Set the background and text colors
        cell.selectedBackgroundView!.backgroundColor = cell.isSelected ? .white : cellBackgroundColor
        cell.tagTitleLabel.textColor = cell.isSelected ? .black : .white
    }
}

// MARK: - Extensions

// This extention houses table view management functions using the diffable data source API and conforms to the RemoveCashDelegate protocol
extension SelectTagTableViewController {
    
    // Create the the data source and specify what to do with a provided cell
    private func createDataSource() -> UITableViewDiffableDataSource<Section, Tag> {
        
        // Create a locally-scoped copy of cellReuseIdentifier to avoid referencing self in closure below
        let reuseIdentifier = "tagCell"
        
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, tag in
            // Configure the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SelectTagTableViewCell
            
            cell.tagTitleLabel.text = tag.title
            
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
