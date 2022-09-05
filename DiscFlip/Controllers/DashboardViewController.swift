//
//  DashboardViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

import UIKit

// This class/view controller displays running totals and other financial data
class DashboardViewController: UIViewController {
    
    @IBOutlet var totalPurchasedLabel: UILabel!
    @IBOutlet var totalSoldLabel: UILabel!
    @IBOutlet var currentNetLabel: UILabel!
    @IBOutlet var estimatedNetLabel: UILabel!
    
    var inventory = [Disc]()
    
    weak var delegate: InventoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInventory()
        
        updateUI()
    }
    
    // Fetch the inventory
    func loadInventory() {
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
    }
    
    // Calculate totals and present to screen
    func updateUI() {
        let totalPurchased = inventory.reduce(0) { $0 + $1.purchasePrice }
        totalPurchasedLabel.text = "Total Purchased: $" + String(totalPurchased)
        
        let totalSold = inventory.reduce(0) { $0 + $1.soldPrice }
        totalSoldLabel.text = "Total Sold: $" + String(totalSold)
        
        currentNetLabel.text = "Current Net: $" + String(totalSold - totalPurchased)
        
        let estimatedNet = inventory.reduce(0) { $0 + $1.estSellPrice }
        estimatedNetLabel.text = "Estimated Net (conservative): $" + String(estimatedNet - totalPurchased)
    }
}
