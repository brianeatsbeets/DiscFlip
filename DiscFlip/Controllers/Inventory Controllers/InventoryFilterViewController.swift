//
//  InventoryFilterViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/26/22.
//

import UIKit

class InventoryFilterViewController: UIViewController {
    
    @IBOutlet var soldDiscButton: UIButton!
    @IBOutlet var soldOnEbayButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonMenus()
    }
    
    func setupButtonMenus() {
        let soldDiscYes = UIAction(title: "Yes") { _ in
          print("Users action was tapped")
        }
        let soldDiscNo = UIAction(title: "No") { _ in
          print("Users action was tapped")
        }
        let soldDiscAll = UIAction(title: "All", state: .on) { _ in
          print("Users action was tapped")
        }

        let soldDiscMenu = UIMenu(options: .displayInline, children: [soldDiscYes, soldDiscNo, soldDiscAll])
        
        soldDiscButton.menu = soldDiscMenu
        
        let soldOnEbayYes = UIAction(title: "Yes") { _ in
          print("Users action was tapped")
        }
        let soldOnEbayNo = UIAction(title: "No") { _ in
          print("Users action was tapped")
        }
        let soldOnEbayAll = UIAction(title: "All", state: .on) { _ in
          print("Users action was tapped")
        }

        let soldOnEbayMenu = UIMenu(options: .displayInline, children: [soldOnEbayYes, soldOnEbayNo, soldOnEbayAll])
        
        soldOnEbayButton.menu = soldOnEbayMenu
    }
}

enum SoldDiscFilter {
    case sold, notSold, all
}

enum SoldOnEbayFilter {
    case soldOnEbay, notSoldOnEbay, all
}
