//
//  DashboardViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/29/22.
//

import UIKit

// This protocol allows the inventory to be updated by other views
protocol InventoryDelegate {
    func updateInventory(newInventory: [Disc])
}

// This class/view controller displays running totals and other financial data
class DashboardViewController: UIViewController {
    
    var inventory = [Disc]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

// This extension of DashboardViewController conforms to the InventoryDelegate protocol
extension DashboardViewController: InventoryDelegate {
    func updateInventory(newInventory: [Disc]) {
        inventory = newInventory
    }
}
