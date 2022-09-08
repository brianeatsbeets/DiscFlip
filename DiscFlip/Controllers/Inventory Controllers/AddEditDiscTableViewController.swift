//
//  AddEditDiscTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/30/22.
//

import UIKit

// This class/table view controller handles the creating of new discs and editing of existing discs
class AddEditDiscTableViewController: UITableViewController {

    var disc: Disc?
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var plasticTextField: UITextField!
    @IBOutlet var purchasePriceTextField: UITextField!
    @IBOutlet var estSellPriceTextField: UITextField!
    @IBOutlet var soldPriceTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // Initialize with disc data
    init?(coder: NSCoder, disc: Disc?) {
        self.disc = disc
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        updateUI()
        
        updateSaveButtonState()
        
        super.viewDidLoad()
    }
    
    // Fill in existing disc data (if any) and update view title
    func updateUI() {
        if let disc = disc {
            nameTextField.text = disc.name
            plasticTextField.text = disc.plastic
            purchasePriceTextField.text = String(disc.purchasePrice)
            estSellPriceTextField.text = String(disc.estSellPrice)
            soldPriceTextField.text = String(disc.soldPrice)
            title = "Edit Disc"
        } else {
            title = "Add Disc"
        }
    }
    
    // Enable and disable the save button based on text field validation
    func updateSaveButtonState() {
        let nameText = nameTextField.text ?? ""
        let plasticText = plasticTextField.text ?? ""
        let purchasePriceText = purchasePriceTextField.text ?? ""
        let estSellPriceText = estSellPriceTextField.text ?? ""
        saveButton.isEnabled = !nameText.isEmpty && !plasticText.isEmpty &&
        !purchasePriceText.isEmpty && !estSellPriceText.isEmpty
    }
    
    // Trigger the save button state update when text is edited
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // MARK: - Navigation
    
    // Compile the disc data for sending back to the inventory table view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Make sure we're saving and not cancelling
        guard segue.identifier == "saveUnwind" else { return }
        
        let name = nameTextField.text!
        let plastic = plasticTextField.text!
        let purchasePrice = Int(purchasePriceTextField.text!) ?? 0
        let estSellPrice = Int(estSellPriceTextField.text!) ?? 0
        let soldPrice = soldPriceTextField.text!.isEmpty ? 0 : Int(soldPriceTextField.text!)!
        
        disc = Disc(name: name, plastic: plastic, purchasePrice: purchasePrice, estSellPrice: estSellPrice, soldPrice: soldPrice)
    }

}