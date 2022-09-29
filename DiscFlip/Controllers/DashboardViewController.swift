//
//  DashboardViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// This protocol allows other view controllers that have the conforming view controller (DashboardViewController) as a delegate to update the overall cash list without being directly coupled with the main tab bar controller
protocol SaveCashDelegate: AnyObject {
    func saveCash(newCashList: [Cash])
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
    }
    
    // MARK: - Navigation
    
    // Initialize the cash table view controller with the existing cash list
    @IBSegueAction func segueToCash(_ coder: NSCoder) -> CashTableViewController? {
        let cashTVC = CashTableViewController(coder: coder, cashList: cashList)
        
        // Allow the cash view controller to update the overall cash list via our existing delegate to cover all dismissal navigation cases
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
    }
    
    // Allow the dashboard view controller to be aware of presentation controller events for the destination view controller (CashTableViewController)
    // This is to handle the specific case of navigating back to the dashboard from the cash table view controller via tapping the dashboard tab bar item, but it also accounts for tapping the back navigation bar button item
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.presentationController?.delegate = self
    }
}

// MARK: - Extensions

// This extension allows the cash table view controller to update the overall cash list without being directly coupled with the main tab bar controller
extension DashboardViewController: SaveCashDelegate {
    func saveCash(newCashList: [Cash]) {
        delegate?.updateCashList(newCashList: newCashList)
    }
}

// This extension updates the dashboard totals when the cash table view controller is dismissed
extension DashboardViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        calculateTotals()
    }
}
