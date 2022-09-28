//
//  CashTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/6/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// This protocal allows conformers to remove cash
protocol CashDelegate: AnyObject {
    func remove(cash: Cash)
}

// MARK: - Main class

// This class/table view controller displays cash funds that have been added
class CashTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    var cashList: [Cash]
    let cellReuseIdentifier = "cashCell"
    private lazy var dataSource = createDataSource()
    weak var delegate: ReturnFromCash?
    
    // MARK: - Initializers
    
    // Initialize with cash data
    init?(coder: NSCoder, cashList: [Cash]) {
        self.cashList = cashList
        super.init(coder: coder)
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
        
        updateTableView()
    }
    
    // MARK: - Navigation
    
    // Configure the incoming AddEditCashTableViewControler for either editing an existing cash object or adding a new one
    @IBSegueAction func addEditCash(_ coder: NSCoder, sender: Any?) -> AddEditCashTableViewController? {
        
        // Check to see if a cell was tapped and if there is a cash object associated with that indexPath
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let cashToEdit = dataSource.itemIdentifier(for: indexPath) {
            // If so, pass the tapped cash to edit
            return AddEditCashTableViewController(coder: coder, cash: cashToEdit)
        } else {
            // If not, prep for adding new cash
            return AddEditCashTableViewController(coder: coder, cash: nil)
        }
    }
    
    // Handle the incoming data being passed back from AddEditCashTableViewController, if any
    @IBAction func unwindToCashTableViewController(segue: UIStoryboardSegue) {
        
        // Check to see if we're coming back from saving cash. If not, exit with guard and deselect the row
        guard segue.identifier == "cashSaveUnwind",
              let sourceViewController = segue.source as? AddEditCashTableViewController,
              let returnedCash = sourceViewController.cash
        else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: false)
            }
            
            return
        }
        
        // Check to see if cash was selected from editing, and if so, update it
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
            cashList[selectedIndexPath.row] = returnedCash
            updateTableView()
        } else {
            // If not, add new cash object to the array and add a new table view row
            cashList.append(returnedCash)
            updateTableView()
        }
        
        Cash.saveCash(cashList)
        
        delegate?.saveData(newCashList: cashList)
    }
}

// MARK: - Extensions

// This extention houses table view management functions using the diffable data source API and conforms to the CashDelegate protocol
extension CashTableViewController: CashDelegate {
    
    // Create the the data source and specify what to do with a provided cell
    private func createDataSource() -> DeletableRowTableViewDiffableDataSource {
        
        // Create a locally-scoped copy of cellReuseIdentifier to avoid referencing self in closure below
        let reuseIdentifier = cellReuseIdentifier
        
        return DeletableRowTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, cash in
            // Configure the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            
            content.text = cash.amount.currencyWithPolarity()
            content.textProperties.font = UIFont(name: "Arial Rounded MT Bold", size: 22) ?? .preferredFont(forTextStyle: .body)
            content.textProperties.color = .white
            
            content.secondaryText = cash.memo
            content.secondaryTextProperties.font = UIFont(name: "Arial Rounded MT Bold", size: 13) ?? .preferredFont(forTextStyle: .body)
            content.secondaryTextProperties.color = .white
            
            cell.contentConfiguration = content
            
            return cell
        }
    }
    
    // Apply a snapshot with updated cash data
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Cash>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(cashList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // Apply a snapshot with removed cash data
    func remove(cash: Cash) {
        
        // Remove cash from cashList
        cashList = cashList.filter { $0 != cash }
        
        // Remove cash from the snapshot and apply it
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([cash])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        // Save the cash list to file
        Cash.saveCash(cashList)
    }
}

// MARK: - Enums

// This enum declares table view sections
private enum Section: CaseIterable {
    case one
}

// MARK: - Other classes

// This class defines a UITableViewDiffableDataSource subclass that enables swipe-to-delete
private class DeletableRowTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Cash> {
    
    // MARK: - Class properties
    
    // Delegate to update data model
    weak var delegate: CashDelegate?
    
    // MARK: - Utility functions
    
    // Allow the table view to be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Allow table view rows to be deleted
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let cashToDelete = itemIdentifier(for: indexPath) {
            delegate?.remove(cash: cashToDelete)
        }
    }
}
