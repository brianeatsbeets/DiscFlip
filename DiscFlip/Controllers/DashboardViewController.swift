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
    var cashList = [Cash]()
    
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
            cashList = initialCash
        } else {
            print("Failed to fetch initial Cash from DashboardViewController")
        }
    }
    
    // Calculate totals and present to screen
    func updateUI() {
        let totalPurchased = inventory.reduce(0) { $0 + $1.purchasePrice }
        totalPurchasedLabel.text = totalPurchased.currencyWithPolarity()
        
        let totalSold = inventory.reduce(0) { $0 + ($1.wasSold ? $1.soldPrice : 0) }
        totalSoldLabel.text = totalSold.currencyWithPolarity()
        
        let otherCash = cashList.reduce(0) { $0 + $1.amount }
        otherCashLabel.text = otherCash.currencyWithPolarity()
        
        let currentNet = totalSold - totalPurchased + otherCash
        currentNetLabel.text = currentNet.currencyWithPolarity()
        
        let estimatedGross = inventory.reduce(0) { $0 + ($1.wasSold ? 0 : $1.estSellPrice) }
        let estimatedNet = totalSold - totalPurchased + estimatedGross + otherCash
        estimatedNetLabel.text = estimatedNet.currencyWithPolarity()
        
        let eBayNet = inventory.reduce(0) { $0 + ($1.wasSold && $1.soldOnEbay ? $1.eBayProfit : 0) }
        eBayNetLabel.text = eBayNet.currencyWithPolarity()
    }
    
    // Initialize the cash table view controller with the existing cash array
    @IBSegueAction func segueToCash(_ coder: NSCoder) -> CashTableViewController? {
        return CashTableViewController(coder: coder, cashList: cashList)
    }
    
    // Receive cash data from CashViewController and update dashboard
    @IBAction func unwindToDashboardViewController(segue: UIStoryboardSegue) {

        // Check to see if we're coming back from viewing cash. If not, exit with guard
        guard segue.identifier == "dashboardCashUnwind",
              let sourceViewController = segue.source as? CashTableViewController else { return }
        
        let returnedCash = sourceViewController.cashList
        
        print("Received cash from CashViewController: \(returnedCash)")
        
        cashList = returnedCash
        
        updateUI()
        
        delegate?.updateCash(newCash: returnedCash)
    }
    
}
