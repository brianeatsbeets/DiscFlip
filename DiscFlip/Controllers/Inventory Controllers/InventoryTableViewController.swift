//
//  InventoryTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// This protocol allows conformers to remove discs from the inventory
protocol InventoryDelegate: AnyObject {
    func remove(disc: Disc)
}

// This protocol allows conformers to filter the inventory
protocol InventoryFilterDelegate: AnyObject {
    func filterInventory(filter: InventoryFilter)
}

// MARK: - Main class

// This class/table view controller displays the historic inventory of discs that have been bought and sold
class InventoryTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    var inventory = [Disc]()
    let cellReuseIdentifier = "inventoryCell"
    private lazy var dataSource = createDataSource()
    weak var delegate: DataDelegate?
    var currentFilter = InventoryFilter.all
    
    // IBOutlets
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var currentFilterView: UIView!
    @IBOutlet var currentFilterLabel: UILabel!
    
    // MARK: - View life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
        
        loadInventory()
        stylizeBarButtonItems()
        updateTableView()
        
        initializeFilterViews()
    }
    
    // MARK: - Utility functions
    
    // Fetch the inventory
    func loadInventory() {
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
    }
    
    // Stylize bar button items for the current navigation stack
    func stylizeBarButtonItems() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .normal)
    }
    
    // Set initial label text and round the corners
    func initializeFilterViews() {
        currentFilterLabel.text = currentFilter.rawValue
        currentFilterView.layer.masksToBounds = true
        currentFilterView.layer.cornerRadius = 10
    }
    
    // MARK: - Navigation
    
    // Prep for specific segue cases
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set the destination presentation controller delegate to self in order to be notified of manual view dismissals (see UIAdaptivePresentationControllerDelegate extension below)
        segue.destination.presentationController?.delegate = self
        
        // Check if we're segueing to the inventory filter
        // If so, configure the inventory filter view controller and its presentation
        guard let inventoryFilterTVC = segue.destination as? InventoryFilterTableViewController,
              segue.identifier == "InventoryFilter" else { return }
        inventoryFilterTVC.presentationController?.delegate = self
        inventoryFilterTVC.preferredContentSize = CGSize(width: 325, height: 240)
        inventoryFilterTVC.delegate = self
        inventoryFilterTVC.selectedFilter = currentFilter
    }
    
    // Configure the incoming AddEditDiscTableViewControler for either editing an existing disc or adding a new one
    @IBSegueAction func addEditDisc(_ coder: NSCoder, sender: Any?) -> UITableViewController? {
        
        // Check to see if a cell was tapped
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let discToEdit = dataSource.itemIdentifier(for: indexPath) {
            // If so, pass the tapped disc to edit
            return AddEditDiscTableViewController(coder: coder, disc: discToEdit)
        } else {
            // If not, prep for adding a new disc
            return AddEditDiscTableViewController(coder: coder, disc: nil)
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
extension InventoryTableViewController: InventoryFilterDelegate {
    func filterInventory(filter: InventoryFilter) {
        
        // Update this view controller's filter value to the one that was selected in the inventory filter view controller
        currentFilter = filter
        
        var filteredInventory = inventory
        
        // Filter inventory
        switch filter {
        case .unsold:
            filteredInventory = filteredInventory.filter { !$0.wasSold }
        case .soldAll:
            filteredInventory = filteredInventory.filter { $0.wasSold }
        case .soldOnEbay:
            filteredInventory = filteredInventory.filter { $0.wasSold && $0.soldOnEbay }
        case .soldNotOnEbay:
            filteredInventory = filteredInventory.filter { $0.wasSold && !$0.soldOnEbay }
        default:
            break
        }
        
        // Update the table view with the filtered data
        currentFilterLabel.text = filter.rawValue
        updateTableView(newInventory: filteredInventory, animated: false)
    }
}

// This extention houses table view management functions using the diffable data source API and conforms to the InventoryDelegate protocol
extension InventoryTableViewController: InventoryDelegate {
    
    // Create the the data source and specify what to do with a provided cell
    private func createDataSource() -> DeletableRowTableViewDiffableDataSource {
        
        // Create a locally-scoped copy of cellReuseIdentifier to avoid referencing self in closure below
        let reuseIdentifier = cellReuseIdentifier
        
        return DeletableRowTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, disc in
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
    
                if !disc.soldOnEbay {
                    secondaryText += " | Not sold on eBay"
                }
            }
    
            content.secondaryText = secondaryText
            content.secondaryTextProperties.font = UIFont(name: "Arial Rounded MT Bold", size: 13) ?? .preferredFont(forTextStyle: .body)
            content.secondaryTextProperties.color = .white
            
            cell.contentConfiguration = content
            
            return cell
        }
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
    weak var delegate: InventoryDelegate?
    
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
