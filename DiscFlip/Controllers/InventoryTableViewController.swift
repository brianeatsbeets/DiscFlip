//
//  InventoryTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// TODO: Allow for deletion of discs - brainstorm best way to implement (here or on edit screen?)

import UIKit

// This class/table view controller displays the historic inventory of discs that have been bought and sold
class InventoryTableViewController: UITableViewController {
    
    var inventory = [Disc]()
    
    weak var delegate: InventoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInventory()
        tableView.reloadData()
    }
    
    // Fetch the inventory
    func loadInventory() {
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
    }

    // MARK: - Table view data source
    
    // Define the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Define the number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inventory.count
    }

    // Configure the cell at a given row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath)
        let disc = inventory[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = disc.plastic + " " + disc.name
        content.secondaryText = "Purchase price: $\(disc.purchasePrice)"
        cell.contentConfiguration = content

        return cell
    }
    
    // Configure the incoming AddEditDiscTableViewControler for either editing an existing disc or adding a new one
    @IBSegueAction func addEditDisc(_ coder: NSCoder, sender: Any?) -> UITableViewController? {
        
        // Check to see if a cell was tapped
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            // If so, pass the tapped disc to edit
            let discToEdit = inventory[indexPath.row]
            return AddEditDiscTableViewController(coder: coder, disc: discToEdit)
        } else {
            // If not, prep for adding a new disc
            return AddEditDiscTableViewController(coder: coder,
               disc: nil)
        }
    }
    
    // Handle the incoming data being passed back from AddEditTableViewController, if any
    @IBAction func unwindToInventoryTableViewController(segue: UIStoryboardSegue) {
        
        // Check to see if we're coming back from saving a disc. If not, exit with guard
        guard segue.identifier == "saveUnwind",
                let sourceViewController = segue.source as? AddEditDiscTableViewController,
                let disc = sourceViewController.disc else { return }
        
        // Check to see if a disc was selected form editing, and if so, update it
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            inventory[selectedIndexPath.row] = disc
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            // If not, add a new disc to the inventory and add a new table view row
            let newIndexPath = IndexPath(row: inventory.count, section: 0)
            inventory.append(disc)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        
        delegate?.updateInventory(newInventory: inventory)
        
        saveInventory()
    }
    
    // Save the updated inventory
    func saveInventory() {
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("inventory") . appendingPathExtension("plist")
        
        // Encode data
        let propertyListEncoder = PropertyListEncoder()
        if let encodedInventory = try? propertyListEncoder.encode(inventory) {
            // Save inventory
            try? encodedInventory.write(to: archiveURL, options: .noFileProtection)
        }
        
        print("Saved inventory to data source: \(inventory)")
    }

}
