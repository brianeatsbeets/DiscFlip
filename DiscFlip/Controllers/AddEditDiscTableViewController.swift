//
//  AddEditDiscTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/30/22.
//

import UIKit

class AddEditDiscTableViewController: UITableViewController {

    var disc: Disc?
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var plasticTextField: UITextField!
    @IBOutlet var purchasePriceTextField: UITextField!
    @IBOutlet var estSellingPriceTextField: UITextField!
    @IBOutlet var soldPriceTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    
    init?(coder: NSCoder, disc: Disc?) {
        self.disc = disc
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        if let disc = disc {
            nameTextField.text = disc.name
            plasticTextField.text = disc.plastic
            purchasePriceTextField.text = String(disc.purchasePrice)
            estSellingPriceTextField.text = String(disc.estSellPrice)
            soldPriceTextField.text = String(disc.soldPrice)
            title = "Edit Disc"
        } else {
            title = "Add Disc"
        }
        
        updateSaveButtonState()
        
        super.viewDidLoad()
    }
    
    func updateSaveButtonState() {
        let nameText = nameTextField.text ?? ""
        let plasticText = plasticTextField.text ?? ""
        let purchasePriceText = purchasePriceTextField.text ?? ""
        let estSellingPriceText = estSellingPriceTextField.text ?? ""
        saveButton.isEnabled = !nameText.isEmpty && !plasticText.isEmpty &&
        !purchasePriceText.isEmpty && !estSellingPriceText.isEmpty
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }

}
