//
//  InventoryTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

import UIKit

class InventoryTableViewController: UITableViewController {
    
    var inventory: [Disc] = [Disc(name: "Thunderbird", plastic: "Champion", purchasePrice: 17, estSellPrice: 12)]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inventory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath)
        let disc = inventory[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = disc.plastic + " " + disc.name
        content.secondaryText = "Purchase price: $\(disc.purchasePrice)"
        cell.contentConfiguration = content

        return cell
    }
    
    @IBSegueAction func addEditDisc(_ coder: NSCoder, sender: Any?) -> UITableViewController? {
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            // Editing Disc
            let discToEdit = inventory[indexPath.row]
            return AddEditDiscTableViewController(coder: coder, disc: discToEdit)
        } else {
            // Adding Emoji
            return AddEditDiscTableViewController(coder: coder,
               disc: nil)
        }
    }
    
    @IBAction func unwindToInventoryTableViewController(segue: UIStoryboardSegue) {
        // Check if we're coming back from saving a disc
        guard segue.identifier == "saveUnwind",
                let sourceViewController = segue.source as? AddEditDiscTableViewController,
                let disc = sourceViewController.disc else { return }
        
        // Check if a disc was selected form editing, and if so, update it
        // If not, add a new row
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            inventory[selectedIndexPath.row] = disc
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            let newIndexPath = IndexPath(row: inventory.count, section: 0)
            inventory.append(disc)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
