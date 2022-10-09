//
//  InventoryTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// TODO: Create a flowchart for the filtering workflows

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// This protocol allows conformers to remove discs from the inventory
protocol RemoveInventoryDelegate: AnyObject {
    func remove(disc: Disc)
}

// This protocol allows conformers to filter the inventory
protocol TagFilterDelegate: AnyObject {
    func filterInventory(tagFilters: [Tag]?)
}

// This protocol allows conformers to remove tag filters
protocol RemoveTagFilterDelegate: AnyObject {
    func removeFilter(_ filterView: FilterContainerView)
}

// MARK: - Main class

// This class/table view controller displays the historic inventory of discs that have been bought and sold
class InventoryTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    var inventory = [Disc]()
    var tags = [Tag]()
    
    let cellReuseIdentifier = "inventoryCell"
    private lazy var dataSource = createDataSource()
    weak var delegate: DataDelegate?
    
    var activeStandardFilter = InventoryFilter.all
    var activeTagFilters = [Tag]()
    var activeTagFilterViews = [FilterContainerView]()
    
    // IBOutlets
    @IBOutlet var filterContainerView: UIView!
    @IBOutlet var tagFilterButton: UIButton!
    @IBOutlet var standardFilterSegmentedControl: UISegmentedControl!
    @IBOutlet var filterLabelsStackView: UIStackView!
    
    // MARK: - View life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
        
        loadData()
        stylizeBarButtonItems()
        initializeSegmentedControl()
        updateTableView()
    }
    
    // MARK: - Utility functions
    
    // Fetch the inventory
    func loadData() {
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
        
        if let initialTags = delegate?.checkoutTags() {
            tags = initialTags
        } else {
            print("Failed to fetch initial tags from DashboardViewController")
        }
    }
    
    // Stylize bar button items for the current navigation stack
    func stylizeBarButtonItems() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .normal)
    }
    
    // Stylize segmented control text and add filter segments
    func initializeSegmentedControl() {
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 13) ?? .preferredFont(forTextStyle: .body)], for: .normal)
        standardFilterSegmentedControl.removeAllSegments()
        InventoryFilter.allCases.forEach {
            standardFilterSegmentedControl.insertSegment(withTitle: $0.rawValue, at: standardFilterSegmentedControl.numberOfSegments, animated: false)
            standardFilterSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    // Adjust filter container view height based on active filters
    func toggleFilterContainerViewHeight() {
        
        // Check if there are no active filters (standard or tag) and that the filter container view has the taller height
        if activeTagFilters.isEmpty && filterContainerView.frame.height == 88 {
            
            // Decrease the height of the filter container view to make room for the filter labels
            UIView.animate(withDuration: 0.3, animations: { [self] in
                filterContainerView.frame = CGRect(
                    x: Int(filterContainerView.frame.origin.x),
                    y: Int(filterContainerView.frame.origin.y),
                    width: Int(filterContainerView.frame.width),
                    height: 44)
            })
            
            // Check if there are active filters (standard or tag) and that the filter container view has the shorter height
        } else if !activeTagFilters.isEmpty && filterContainerView.frame.height == 44 {
            
            // Increase the height of the filter container view to make room for the filter labels
            UIView.animate(withDuration: 0.3, animations: { [self] in
                filterContainerView.frame = CGRect(
                    x: Int(filterContainerView.frame.origin.x),
                    y: Int(filterContainerView.frame.origin.y),
                    width: Int(filterContainerView.frame.width),
                    height: 88)
            })
        }
    }
    
    // Create a filter view for a tag filter
    func createFilterView(tagFilter: Tag) {
        
        // Initialize the new filter view
        let newFilterView = FilterContainerView(tagFilter: tagFilter)
        newFilterView.delegate = self
            
        // Add the tag and its view to the respective arrays and add the view to the filter stack view
        activeTagFilters.append(tagFilter)
        activeTagFilterViews.append(newFilterView)
        filterLabelsStackView.addArrangedSubview(newFilterView)
        
        // Animate the new filter addition
        newFilterView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.2) {
            newFilterView.transform = .identity
        }
    }
    
    @IBAction func standardFilterSelected(_ sender: UISegmentedControl) {
        activeStandardFilter = InventoryFilter.allCases[sender.selectedSegmentIndex]
        filterInventory()
    }
    
    // This is a temporary function/IBAction to test out filtering with tags
    @IBAction func createTag(_ sender: Any) {
        createFilterView(tagFilter: Tag(title: "Tag"))
        filterInventory(tagFilters: activeTagFilters)
    }
    
    // MARK: - Navigation
    
    // Prep for specific segue cases
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set the destination presentation controller delegate to self in order to be notified of manual view dismissals (see UIAdaptivePresentationControllerDelegate extension below)
        segue.destination.presentationController?.delegate = self
        
        
        // TODO: Instantiate via @IBSegueAction instead
        // Check if we're segueing to the inventory filter
        // If so, configure the inventory filter view controller and its presentation
        guard let tagFilterTVC = segue.destination as? TagFilterTableViewController,
              segue.identifier == "TagFilter" else { return }
        tagFilterTVC.presentationController?.delegate = self
        tagFilterTVC.preferredContentSize = CGSize(width: 325, height: 44 * (tags.count + 1))
        tagFilterTVC.delegate = self
        tagFilterTVC.allTags = tags
        tagFilterTVC.selectedTags = activeTagFilters
        tagFilterTVC.context = .inventoryFilter
    }
    
    // Configure the incoming AddEditDiscTableViewController for either editing an existing disc or adding a new one
    @IBSegueAction func addEditDisc(_ coder: NSCoder, sender: Any?) -> UITableViewController? {
        
        // Check to see if a cell was tapped
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let discToEdit = dataSource.itemIdentifier(for: indexPath) {
            // If so, pass the tapped disc to edit
            return AddEditDiscTableViewController(coder: coder, disc: discToEdit, tags: tags)
        } else {
            // If not, prep for adding a new disc
            return AddEditDiscTableViewController(coder: coder, disc: nil, tags: tags)
        }
    }
    
    // Handle the incoming data being passed back from AddEditDiscTableViewController, if any
    @IBAction func unwindToInventoryTableViewController(segue: UIStoryboardSegue) {
        
        // Check to see if we're coming back from saving a disc. If not, exit with guard and deselect the row
        guard segue.identifier == "saveUnwind",
              let sourceViewController = segue.source as? AddEditDiscTableViewController,
              let disc = sourceViewController.disc
        else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: false)
            }
            
            return
        }
        
        // Check to see if a disc was selected for editing, and if so, update it
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
            inventory[selectedIndexPath.row] = disc
            updateTableView()
        } else {
            // If not, add a new disc to the inventory and add a new table view row
            inventory.append(disc)
            updateTableView()
        }
        
        delegate?.updateInventory(newInventory: inventory)
        
        Disc.saveInventory(inventory)
    }
}
    
// MARK: - Extensions

// This extension handles deselecting the selected row when the user manually swipes away the modally presented view controller (AddEditDiscTableViewController)
extension InventoryTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
}

// This extension allows the InventoryFilterViewController to have customizable dimensions
extension InventoryTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
    
// This extension processes filter selections and filters the table view data appropriately
extension InventoryTableViewController: TagFilterDelegate {
    func filterInventory(tagFilters: [Tag]? = nil) {
        
        var filteredInventory = inventory
        
        // Check to see if we have tags to filter on
        if let tagFilters = tagFilters {
            
            // Compare new tag filters to existing tag filters and remove as necessary
            for (index, activeTagFilter) in activeTagFilters.enumerated() {
                if tagFilters.firstIndex(of: activeTagFilter) == nil {
                    removeFilter(activeTagFilterViews[index])
                    
                    // filterInventory will be called again in removeFilter, so we don't need to continue with this current call
                    return
                }
            }
            
            // Add new tag filters and views
            for tagFilter in tagFilters {
                
                // Create tag filter views for new tag filters
                if activeTagFilters.firstIndex(of: tagFilter) == nil {
                    createFilterView(tagFilter: tagFilter)
                }
            }
        }
        
        // Filter the inventory on the active tag filters
        for tagFilter in activeTagFilters {
            filteredInventory = filteredInventory.filter { $0.tags.firstIndex(of: tagFilter) != nil }
        }
        
        // Filter the inventory on the standard filter
        switch activeStandardFilter {
        case .unsold:
            filteredInventory = filteredInventory.filter { !$0.wasSold }
        case .sold:
            filteredInventory = filteredInventory.filter { $0.wasSold }
        default:
            break
        }
        
        toggleFilterContainerViewHeight()
        updateTableView(newInventory: filteredInventory, animated: true)
    }
}

// This extension handles the removal of filters
extension InventoryTableViewController: RemoveTagFilterDelegate {
    
    // Remove the selected filter from the view and data structures
    func removeFilter(_ filterView: FilterContainerView) {
        guard let index = self.activeTagFilterViews.firstIndex(of: filterView) else { return }
            
        // Remove the tag filter and view
        self.activeTagFilterViews.remove(at: index)
        self.activeTagFilters.remove(at: index)
        
        // Animate filter view removal
        UIView.animate(withDuration: 0.15, animations: {
            filterView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { [self] _ in
            filterInventory(tagFilters: activeTagFilters)
            
            UIView.animate(withDuration: 0.17, animations: {
                filterView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }) { _ in
                
                UIView.animate(withDuration: 0.2, animations: {
                    filterView.isHidden = true
                }) { (_) in
                    filterView.removeFromSuperview()
                }
            }
        }
    }
}

// This extention houses table view management functions using the diffable data source API and conforms to the InventoryDelegate protocol
extension InventoryTableViewController: RemoveInventoryDelegate {
    
    // Create the the data source and specify what to do with a provided cell
    private func createDataSource() -> DeletableRowTableViewDiffableDataSource {
        
        // Create a locally-scoped copy of cellReuseIdentifier to avoid referencing self in closure below
        let reuseIdentifier = cellReuseIdentifier
        
        let dataSource = DeletableRowTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, disc in
            // Configure the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            content.text = disc.plastic + " " + disc.name
            content.textProperties.font = UIFont(name: "Arial Rounded MT Bold", size: 22) ?? .preferredFont(forTextStyle: .body)
            content.textProperties.color = .white
    
            var secondaryText = ""
    
            // Create applicable profit statements
            if !disc.wasSold {
                secondaryText = "Estimated profit: " + (disc.estSellPrice - disc.purchasePrice).currencyWithPolarity()
            } else {
                let profit = disc.soldPrice - disc.purchasePrice
                secondaryText = "Profit: " + profit.currencyWithPolarity()
            }
    
            content.secondaryText = secondaryText
            content.secondaryTextProperties.font = UIFont(name: "Arial Rounded MT Bold", size: 13) ?? .preferredFont(forTextStyle: .body)
            content.secondaryTextProperties.color = .white
            
            cell.contentConfiguration = content
            
            return cell
        }
        
        // Set the animation style for inserting and removing rows
        dataSource.defaultRowAnimation = .left
        
        return dataSource
    }
    
    // Apply a snapshot with updated disc data
    func updateTableView(newInventory: [Disc]? = nil, animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Disc>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(newInventory ?? inventory)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // Apply a snapshot with removed disc data
    func remove(disc: Disc) {
        
        // Remove disc from inventory
        inventory = inventory.filter { $0 != disc }
        
        // Remove disc from the snapshot and apply it
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([disc])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        delegate?.updateInventory(newInventory: inventory)
        
        Disc.saveInventory(inventory)
    }
}

// MARK: - Enums

// This enum defines table view sections
private enum Section: CaseIterable {
    case one
}

// MARK: - Other classes

// This class defines a UITableViewDiffableDataSource subclass that enables swipe-to-delete
private class DeletableRowTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Disc> {
    
    // MARK: - Class properties
    
    // Delegate to update data model
    weak var delegate: RemoveInventoryDelegate?
    
    // MARK: - Utility functions
    
    // Allow the table view to be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Allow table view rows to be deleted
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let discToDelete = itemIdentifier(for: indexPath) {
            delegate?.remove(disc: discToDelete)
        }
    }
}
