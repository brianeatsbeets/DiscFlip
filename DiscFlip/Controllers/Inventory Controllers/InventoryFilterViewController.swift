//
//  InventoryFilterViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/26/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

class InventoryFilterViewController: UIViewController {
    
    // MARK: - Class properties
    
    var soldFilter = SoldDiscFilter.all
    var eBayFilter = SoldOnEbayFilter.all
    weak var delegate: InventoryFilterDelegate?
    
    // IBOutlets
    
    @IBOutlet var soldDiscButton: UIButton!
    @IBOutlet var soldOnEbayButton: UIButton!
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonMenus()
    }
    
    // MARK: - Utility functions
    
    // Create and populate filter button menus
    func setupButtonMenus() {
        
        // Sold Disc options
        // If 'No' is selected, disable Sold on eBay filter button; else, enable it
        let soldDiscYes = UIAction(title: "Yes", state: soldFilter == .sold ? .on : .off) { _ in
            self.soldFilter = .sold
            self.soldOnEbayButton.isEnabled = true
        }
        let soldDiscNo = UIAction(title: "No", state: soldFilter == .notSold ? .on : .off) { _ in
            self.soldFilter = .notSold
            self.soldOnEbayButton.isEnabled = false
            
            // Set Sold on eBay filter to 'All' as to not interfere with the Sold Disc filter
            let eBayActions = self.soldOnEbayButton.menu?.children as! [UIAction]
            eBayActions[0].state = .off
            eBayActions[1].state = .off
            eBayActions[2].state = .on
            self.eBayFilter = .all
        }
        let soldDiscAll = UIAction(title: "All", state: soldFilter == .all ? .on : .off) { _ in
            self.soldFilter = .all
            self.soldOnEbayButton.isEnabled = true
        }

        let soldDiscMenu = UIMenu(options: .displayInline, children: [soldDiscYes, soldDiscNo, soldDiscAll])
        
        soldDiscButton.menu = soldDiscMenu
        
        // Sold on eBay options
        let soldOnEbayYes = UIAction(title: "Yes", state: eBayFilter == .soldOnEbay ? .on : .off) { _ in
            self.eBayFilter = .soldOnEbay
        }
        let soldOnEbayNo = UIAction(title: "No", state: eBayFilter == .notSoldOnEbay ? .on : .off) { _ in
            self.eBayFilter = .notSoldOnEbay
        }
        let soldOnEbayAll = UIAction(title: "All", state: eBayFilter == .all ? .on : .off) { _ in
            self.eBayFilter = .all
        }

        let soldOnEbayMenu = UIMenu(options: .displayInline, children: [soldOnEbayYes, soldOnEbayNo, soldOnEbayAll])
        
        soldOnEbayButton.menu = soldOnEbayMenu
        
        soldOnEbayButton.isEnabled = (soldFilter == .notSold ? false : true)
    }
    
    // Apply the filters and dismiss the view
    @IBAction func applyButtonPressed() {
        delegate?.filterInventory(soldDisc: soldFilter, soldOnEbay: eBayFilter)
        dismiss(animated: true)
    }
}

// MARK: - Enums

// This enum defines the Sold Disc filter options
enum SoldDiscFilter: String {
    case sold = "Yes", notSold = "No", all = "All"
}

// This enum defines the Sold on eBay filter options
enum SoldOnEbayFilter: String {
    case soldOnEbay = "Yes", notSoldOnEbay = "No", all = "All"
}
