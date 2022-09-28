//
//  DashboardViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// MARK: - Imported libraries

import UIKit

protocol ReturnFromCash: AnyObject {
    func saveData(newCashList: [Cash])
}

// MARK: - Main class

// This class/view controller displays running totals and other financial data
class DashboardViewController: UIViewController {
    
    // MARK: - Class properties
    
    var inventory = [Disc]()
    var cashList = [Cash]()
    
    weak var delegate: DataDelegate?
    
    // IBOutlets
    
    @IBOutlet var totalPurchasedLabel: UILabel!
    @IBOutlet var totalSoldLabel: UILabel!
    @IBOutlet var otherCashLabel: UILabel!
    @IBOutlet var currentNetLabel: UILabel!
    @IBOutlet var estimatedNetLabel: UILabel!
    @IBOutlet var eBayNetLabel: UILabel!
    
    @IBOutlet var totalPurchasedView: UIView!
    @IBOutlet var totalSoldView: UIView!
    @IBOutlet var otherCashView: UIView!
    @IBOutlet var currentNetView: UIView!
    @IBOutlet var estimatedNetView: UIView!
    @IBOutlet var eBayNetView: UIView!
    
    // MARK: - View life cycle functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
        updateUI()
    }
    
    // MARK: - Utility functions
    
    // Load the inventory and cash data
    func loadData() {
        // Disc inventory
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
        
        // Cash list
        if let initialCash = delegate?.checkoutCashList() {
            cashList = initialCash
        } else {
            print("Failed to fetch initial Cash from DashboardViewController")
        }
    }
    
    // Perform UI initialization
    func updateUI() {
        calculateTotals()
        stylizeDashboardViewsUI()
        stylizeBarButtonItems()
    }
    
    // Calculate totals and present to screen
    func calculateTotals() {
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
    
    // Stylize the dashboard view boxes
    func stylizeDashboardViewsUI() {
        let dashboardViews = [totalPurchasedView, totalSoldView, otherCashView, currentNetView, estimatedNetView, eBayNetView]
        
        for item in dashboardViews {
            item?.layer.cornerRadius = 20
        }
    }
    
    // Stylize bar button items for the current navigation stack
    func stylizeBarButtonItems() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .selected)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .highlighted)
    }
    
    // MARK: - Navigation
    
    // Initialize the cash table view controller with the existing cash list
    @IBSegueAction func segueToCash(_ coder: NSCoder) -> CashTableViewController? {
        // We're assigning an existing delegate as a delegate for a new view controller - "Delegate chaining?" This works but doesn't seem like it's good practice. Should think about how the data source/layout could be re-structured to allow the CashTableViewController to update the data source, or make it so it doesn't have to.
        let cashTVC = CashTableViewController(coder: coder, cashList: cashList)
        cashTVC?.delegate = self
        return cashTVC
    }
    
    // Receive cash data from CashViewController and update dashboard
    @IBAction func unwindToDashboardViewController(segue: UIStoryboardSegue) {

        // Check to see if we're coming back from viewing cash. If not, exit with guard
        guard segue.identifier == "dashboardCashUnwind",
              let sourceViewController = segue.source as? CashTableViewController else { return }
        
        let returnedCash = sourceViewController.cashList
        cashList = returnedCash
        
        //delegate?.updateCashList(newCashList: returnedCash)
        
        updateUI()
    }
    
    // Prep for transitioning back to the dashboard from the cash table view controller via tapping the dashboard tab bar item
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set the destination presentation controller delegate to self in order to be notified of manual view dismissals (see UIAdaptivePresentationControllerDelegate extension below)
        segue.destination.presentationController?.delegate = self
    }
}

// MARK: - Extensions

// This extension....
extension DashboardViewController: ReturnFromCash {
    func saveData(newCashList: [Cash]) {
        delegate?.updateCashList(newCashList: newCashList)
    }
}

// This extension handles deselecting the selected row when the user manually swipes away the modally presented view controller (AddEditDiscTableViewController)
extension DashboardViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        calculateTotals()
    }
}
