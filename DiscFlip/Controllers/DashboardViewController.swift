//
//  DashboardViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

// TODO: Pages/filtered dashboard based on tags
// TODO: Animate box views coming in from left on load

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

// MARK: - Main class

// This class/view controller displays running totals and other financial data
class DashboardViewController: UIViewController {
    
    // MARK: - Class properties
    
    var inventory = [Disc]()
    var dashboardViews = [UIView]()
    var dashboardViewsDidAnimate = false
    
    weak var delegate: DataDelegate?
    
    // IBOutlets
    
    @IBOutlet var totalPurchasedLabel: UILabel!
    @IBOutlet var totalSoldLabel: UILabel!
    @IBOutlet var currentNetLabel: UILabel!
    @IBOutlet var estimatedNetLabel: UILabel!
    
    @IBOutlet var totalPurchasedView: UIView!
    @IBOutlet var totalSoldView: UIView!
    @IBOutlet var currentNetView: UIView!
    @IBOutlet var estimatedNetView: UIView!
    
    // MARK: - View life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashboardViews = [totalPurchasedView, totalSoldView, currentNetView, estimatedNetView]
        
        loadData()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !dashboardViewsDidAnimate {
            animateDashboardViews()
            dashboardViewsDidAnimate = true
        }
    }
    
    // MARK: - Utility functions
    
    // Load the inventory data
    func loadData() {
        // Disc inventory
        if let initialInventory = delegate?.checkoutInventory() {
            inventory = initialInventory
        } else {
            print("Failed to fetch initial inventory from DashboardViewController")
        }
    }
    
    // Perform UI initialization
    func updateUI() {
        calculateTotals()
        stylizeDashboardViewsUI()
        stylizeBarButtonItems()
    }
    
    
    func animateDashboardViews() {
        
        for item in dashboardViews {
            item.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            item.alpha = 0
        }
        
        UIView.animateKeyframes(withDuration: 0.76, delay: 0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                self.estimatedNetView.alpha = 1
                self.estimatedNetView.transform = .identity
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.17, relativeDuration: 0.25) {
                self.currentNetView.alpha = 1
                self.currentNetView.transform = .identity
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.34, relativeDuration: 0.25) {
                self.totalSoldView.alpha = 1
                self.totalSoldView.transform = .identity
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.51, relativeDuration: 0.25) {
                self.totalPurchasedView.alpha = 1
                self.totalPurchasedView.transform = .identity
            }
        }
    }
    
    // Calculate totals and present to screen
    func calculateTotals() {
        let totalPurchased = inventory.reduce(0) { $0 + $1.purchasePrice }
        totalPurchasedLabel.text = totalPurchased.currencyWithPolarity()
        
        let totalSold = inventory.reduce(0) { $0 + ($1.wasSold ? $1.soldPrice : 0) }
        totalSoldLabel.text = totalSold.currencyWithPolarity()
        
        let currentNet = totalSold - totalPurchased
        currentNetLabel.text = currentNet.currencyWithPolarity()
        
        let estimatedGross = inventory.reduce(0) { $0 + ($1.wasSold ? 0 : $1.estSellPrice) }
        let estimatedNet = totalSold - totalPurchased + estimatedGross
        estimatedNetLabel.text = estimatedNet.currencyWithPolarity()
    }
    
    // Stylize the dashboard view boxes
    func stylizeDashboardViewsUI() {
        for item in dashboardViews {
            item.layer.cornerRadius = 20
        }
    }
    
    // Stylize bar button items for the current navigation stack
    func stylizeBarButtonItems() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .normal)
    }
}
