//
//  CashTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/6/22.
//

import UIKit

// This class/table view controller displays cash funds that have been added
class CashTableViewController: UITableViewController {
    
    var cash = [Cash]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    // Define the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Define the number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cash.count
    }
    
    // Configure the cell at a given row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cashCell", for: indexPath)
        let cashItem = cash[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "$\(cashItem.amount)"
        content.secondaryText = "Memo: " + cashItem.memo
        cell.contentConfiguration = content
        
        return cell
    }
    
    // Configure the incoming AddEditCashTableViewControler for either editing an existing cash object or adding a new one
    @IBSegueAction func addEditCash(_ coder: NSCoder, sender: Any?) -> AddEditCashTableViewController? {
        
        // Check to see if a cell was tapped
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            // If so, pass the tapped cash to edit
            let cashToEdit = cash[indexPath.row]
            return AddEditCashTableViewController(coder: coder, cash: cashToEdit)
        } else {
            // If not, prep for adding new cash
            return AddEditCashTableViewController(coder: coder, cash: nil)
        }
    }
    
    // Handle the incoming data being passed back from AddEditCashTableViewController, if any
    @IBAction func unwindToCashTableViewController(segue: UIStoryboardSegue) {
        
        // Check to see if we're coming back from saving cash. If not, exit with guard
        guard segue.identifier == "cashSaveUnwind",
              let sourceViewController = segue.source as? AddEditCashTableViewController,
              let returnedCash = sourceViewController.cash else { return }
        
        // Check to see if cash was selected form editing, and if so, update it
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            cash[selectedIndexPath.row] = returnedCash
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            // If not, add new cash object to the array and add a new table view row
            let newIndexPath = IndexPath(row: cash.count, section: 0)
            cash.append(returnedCash)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
