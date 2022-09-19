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
    @IBOutlet var soldDiscSwitch: UISwitch!
    @IBOutlet var soldOnEbayLabel: UILabel!
    @IBOutlet var soldOnEbaySwitch: UISwitch!
    @IBOutlet var estSellPriceLabel: UILabel!
    @IBOutlet var estSellPriceTextField: UITextField!
    @IBOutlet var soldPriceLabel: UILabel!
    @IBOutlet var soldPriceTextField: UITextField!
    
    @IBOutlet var estSellPriceCell: UITableViewCell!
    
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
        
        // Create a gesture recognizer to dismiss the keyboard when an outside tap is registered
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        super.viewDidLoad()
    }
    
    // Fill in existing disc data (if any) and update view title
    func updateUI() {
        
        if let disc = disc {
            nameTextField.text = disc.name
            plasticTextField.text = disc.plastic
            purchasePriceTextField.text = String(disc.purchasePrice)
            soldDiscSwitch.isOn = disc.wasSold
            soldOnEbaySwitch.isEnabled = soldDiscSwitch.isOn
            soldOnEbaySwitch.isOn = disc.soldOnEbay
            estSellPriceTextField.text = String(disc.estSellPrice)
            soldPriceTextField.text = String(disc.soldPrice)
            
            setSellSoldFieldsHiddenState(sold: disc.wasSold)
            
            title = "Edit Disc"
        } else {
            title = "Add Disc"
            
            soldOnEbaySwitch.isEnabled = false
            
            setSellSoldFieldsHiddenState(sold: false)
        }
    }
    
    // Hide and unhide sell/sold price fields based on boolean parameter
    func setSellSoldFieldsHiddenState(sold: Bool) {
        if sold {
            estSellPriceLabel.isHidden = true
            estSellPriceTextField.isHidden = true
            
            soldPriceLabel.isHidden = false
            soldPriceTextField.isHidden = false
        } else {
            estSellPriceLabel.isHidden = false
            estSellPriceTextField.isHidden = false
            
            soldPriceLabel.isHidden = true
            soldPriceTextField.isHidden = true
        }
    }
    
    // Enable and disable the save button based on text field validation
    func updateSaveButtonState() {
        
        // Only check estSellPrice and soldPrice if soldSwitch is off or on, respectively
        if let nameText = nameTextField.text,
           let plasticText = plasticTextField.text,
           let purchasePriceText = purchasePriceTextField.text,
           let estSellPriceText = estSellPriceTextField.text,
           let soldPriceText = soldPriceTextField.text,
           !nameText.isEmpty &&
            !plasticText.isEmpty &&
            Int(purchasePriceText) != nil &&
            (soldDiscSwitch.isOn ? (Int(soldPriceText) != nil) : Int(estSellPriceText) != nil) {
            
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // Trigger the save button state update when text is edited
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // Trigger enabled state updates for various UI elements
    @IBAction func soldDiscSwitchTapped(_ sender: UISwitch) {
        soldOnEbaySwitch.isEnabled = sender.isOn
        estSellPriceTextField.isEnabled = !sender.isOn
        soldPriceTextField.isEnabled = sender.isOn
        
        setSellSoldFieldsHiddenState(sold: sender.isOn)
        
        updateSaveButtonState()
        
        tableView.beginUpdates()
        if sender.isOn {
            tableView.insertRows(at: [IndexPath(row: 1, section: 3)], with: .middle)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: 3)], with: .middle)
        }
        tableView.endUpdates()
    }
    
    // Dismiss the keyboard when an outside tap is registered
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table view functions

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return soldDiscSwitch.isOn ? 2 : 1
        default:
            return 1
        }
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
        let soldPrice = soldPriceTextField.text!.isEmpty ? 0 : (Int(soldPriceTextField.text!) ?? 0) // Provide a value of zero if field is empty; otherwise, parse and validate it like the previous two fields
        let soldOnEbay = soldOnEbaySwitch.isOn
        
        disc = Disc(name: name, plastic: plastic, purchasePrice: purchasePrice, estSellPrice: estSellPrice, wasSold: soldDiscSwitch.isOn, soldPrice: soldPrice, soldOnEbay: soldOnEbay)
    }
}
