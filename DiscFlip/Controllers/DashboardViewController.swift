//
//  DashboardViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// TODO: Update UI when switching from Inventory tab to Dashboard tab

import UIKit

// This class/view controller displays running totals and other financial data
class DashboardViewController: UIViewController {
    
    @IBOutlet var totalPurchasedLabel: UILabel!
    @IBOutlet var totalSoldLabel: UILabel!
    @IBOutlet var otherCashLabel: UILabel!
    @IBOutlet var currentNetLabel: UILabel!
    @IBOutlet var estimatedNetLabel: UILabel!
    @IBOutlet var eBayNetLabel: UILabel!
    
    var inventory = [Disc]()
    var cash = [Cash]()
    
    weak var delegate: DataDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
        updateUI()
    }
    
    // Load the inventory and cash data
    func loadData() {
        // Disc inventory
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
        
        // Cash
        if let initialCash = delegate?.checkoutCash() {
            cash = initialCash
        } else {
            print("Failed to fetch initial Cash from DashboardViewController")
        }
    }
    
    // Calculate totals and present to screen
    func updateUI() {
        let totalPurchased = inventory.reduce(0) { $0 + $1.purchasePrice }
        totalPurchasedLabel.text = "Total Purchased: $" + String(totalPurchased)
        
        let totalSold = inventory.reduce(0) { $0 + $1.soldPrice }
        totalSoldLabel.text = "Total Sold: $" + String(totalSold)
        
        let otherCash = cash.reduce(0) { $0 + $1.amount }
        otherCashLabel.text = "Other Cash: $" + String(otherCash)
        
        currentNetLabel.text = "Current Net: $" + String(totalSold - totalPurchased + otherCash)
        
        let estimatedNet = inventory.reduce(0) { $0 + $1.estSellPrice }
        estimatedNetLabel.text = "Estimated Net (conservative): $" + String(estimatedNet - totalPurchased + otherCash)
        
        let eBayNet = inventory.reduce(0) { $0 + $1.eBayProfit }
        eBayNetLabel.text = "eBay Net: $" + String(eBayNet)
    }
    
    // Initialize the cash table view controller with the existing cash array
    @IBSegueAction func segueToCash(_ coder: NSCoder) -> CashTableViewController? {
        return CashTableViewController(coder: coder, cash: cash)
    }
    
    // Receive cash data from CashViewController and update dashboard
    @IBAction func unwindToDashboardViewController(segue: UIStoryboardSegue) {

        // Check to see if we're coming back from viewing cash. If not, exit with guard
        guard segue.identifier == "dashboardCashUnwind",
              let sourceViewController = segue.source as? CashTableViewController else { return }
        
        let returnedCash = sourceViewController.cash
        
        print("Received cash from CashViewController: \(returnedCash)")
        
        cash = returnedCash
        
        updateUI()
        
        delegate?.updateCash(newCash: returnedCash)
    }
    
}
