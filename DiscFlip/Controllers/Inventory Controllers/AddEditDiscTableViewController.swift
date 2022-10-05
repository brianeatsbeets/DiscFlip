//
//  AddEditDiscTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/30/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view controller handles the creating of new discs and editing of existing discs
class AddEditDiscTableViewController: UITableViewController {
    
    // MARK: - Class properties

    var disc: Disc?
    
    // IBOutlets
    
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
    
    // MARK: - Initializers
    
    // Initialize with disc data
    init?(coder: NSCoder, disc: Disc?) {
        self.disc = disc
        super.init(coder: coder)
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle methods
    
    override func viewDidLoad() {
        
        updateUI()
        updateSaveButtonState()
        
        // Create a gesture recognizer to dismiss the keyboard when an outside tap is registered
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if disc == nil {
            nameTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - Utility functions
    
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
    
    // Move active text field to the next one, if any
    @IBAction func returnKeyTapped(_ sender: UITextField) {
        let nextTag = sender.tag + 1

        if let nextResponder = tableView.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            sender.resignFirstResponder()
        }
    }
    
    // Trigger enabled state updates for various UI elements
    @IBAction func soldDiscSwitchTapped(_ sender: UISwitch) {
        soldOnEbaySwitch.isEnabled = sender.isOn
        
        // Disable/enable text fields to prevent text entry in non-active fields
        estSellPriceTextField.isEnabled = !sender.isOn
        soldPriceTextField.isEnabled = sender.isOn
        
        // Enable/disable save button based on re-appearing selling/sold price text field values
        updateSaveButtonState()
        
        // Insert or remove sold on eBay row based on whether or not the disc was sold
        tableView.beginUpdates()
        if sender.isOn {
            tableView.insertRows(at: [IndexPath(row: 1, section: 3)], with: .left)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: 3)], with: .left)
        }
        tableView.endUpdates()
        
        updateEstSellSoldPriceCell(sender)
    }
    
    // Show/hide the est sell/sold price labels and text fields while animating the cell to draw the user's attention
    func updateEstSellSoldPriceCell(_ sender: UISwitch) {
        estSellPriceCell.transform = CGAffineTransform(translationX: -estSellPriceCell.frame.width, y: 0)
        estSellPriceCell.alpha = 0
        
        UIView.animate(withDuration: 0.3) { [self] in
            estSellPriceCell.transform = .identity
            
            // Display selling/sold price fields based on whether or not the disc was sold
            setSellSoldFieldsHiddenState(sold: sender.isOn)
            
            estSellPriceCell.alpha = 1
        }
    }
    
    // Dismiss the keyboard when an outside tap is registered
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table view functions
    
    // Set the number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return soldDiscSwitch.isOn ? 2 : 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            cell.clipsToBounds = false
            cell.contentView.clipsToBounds = false
        }
    }
    
    // Provide a view for each section footer
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard section == 2 else { return nil }
        
        let footerView = UIView()
        
        let footerLabel = UILabel()
        footerLabel.numberOfLines = 2
        footerLabel.text = "Include extra costs, such as shipping, tax, etc."
        footerLabel.textColor = .white
        footerLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 12) ?? .preferredFont(forTextStyle: .body)
        footerLabel.adjustsFontSizeToFitWidth = true
        footerLabel.minimumScaleFactor = 0.5
        
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.layer.masksToBounds = true
        
        footerView.addSubview(footerLabel)
        
        let constraints = [
            footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 10),
            footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 5)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return footerView
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
