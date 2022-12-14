//
//  AddEditDiscTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/30/22.
//

// TODO: Add property to exclude disc from financials (and optionally keep in net calculation) - Use case of adding cash or other entities that may not have been "purchased"

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view controller handles the creating of new discs and editing of existing discs
class AddEditDiscTableViewController: UITableViewController {
    
    // MARK: - Class properties

    var disc: Disc?
    var allTags: [Tag]
    var tagsToAssign = [Tag]()
    var dismissKeyboardGestureRecognizer = UITapGestureRecognizer()
    
    // IBOutlets
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var plasticTextField: UITextField!
    @IBOutlet var purchasePriceTextField: UITextField!
    @IBOutlet var soldDiscSwitch: UISwitch!
    @IBOutlet var estSellPriceLabel: UILabel!
    @IBOutlet var estSellPriceTextField: UITextField!
    @IBOutlet var soldPriceLabel: UILabel!
    @IBOutlet var soldPriceTextField: UITextField!
    
    @IBOutlet var estSellPriceCell: UITableViewCell!
    @IBOutlet var tagsCell: UITableViewCell!
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // MARK: - Initializers
    
    // Initialize with disc data
    init?(coder: NSCoder, disc: Disc?, tags: [Tag]) {
        self.disc = disc
        self.allTags = tags
        if let disc = disc {
            tagsToAssign = disc.tags
        }
        super.init(coder: coder)
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        updateSaveButtonState()
        
        tagsCell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        
        // Initialize a gesture recognizer to dismiss the keyboard when an outside tap is registered
        dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
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
            estSellPriceTextField.text = String(disc.estSellPrice)
            soldPriceTextField.text = String(disc.soldPrice)
            
            setSellSoldFieldsHiddenState(sold: disc.wasSold)
            
            title = "Edit Disc"
        } else {
            title = "Add Disc"
            
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
    
    // Add the gesture recognizer to dismiss the keyboard when an outside tap is registered
    @IBAction func textEditingBegan(_ sender: UITextField) {
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
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
        
        // Disable/enable text fields to prevent text entry in non-active fields
        estSellPriceTextField.isEnabled = !sender.isOn
        soldPriceTextField.isEnabled = sender.isOn
        
        // Enable/disable save button based on re-appearing selling/sold price text field values
        updateSaveButtonState()
        
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
    
    // Dismiss the keyboard when an outside tap is registered and remove the gesture recognizer
    @objc func dismissKeyboard() {
        view.endEditing(true)
        view.removeGestureRecognizer(dismissKeyboardGestureRecognizer)
    }
    
    // MARK: - Table view functions
    
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
        
        // Save disc
        if segue.identifier == "saveUnwind" {
            let name = nameTextField.text!
            let plastic = plasticTextField.text!
            let purchasePrice = Int(purchasePriceTextField.text!) ?? 0
            let estSellPrice = Int(estSellPriceTextField.text!) ?? 0
            let soldPrice = soldPriceTextField.text!.isEmpty ? 0 : (Int(soldPriceTextField.text!) ?? 0) // Provide a value of zero if field is empty; otherwise, parse and validate it like the previous two fields
            
            disc = Disc(name: name, plastic: plastic, purchasePrice: purchasePrice, estSellPrice: estSellPrice, wasSold: soldDiscSwitch.isOn, soldPrice: soldPrice, tags: tagsToAssign)
        }
    }
    
    // Configure the incoming SelectTagsTableViewController for selecting tags to assign
    @IBSegueAction func selectTags(_ coder: NSCoder, sender: Any?) -> SelectTagTableViewController? {
        return SelectTagTableViewController(coder: coder, allTags: allTags, currentTags: disc?.tags ?? [Tag]())
    }
    
    // Handle the incoming data being passed back from TagFilterDiscTableViewController
    @IBAction func unwindToAddEditDiscTableViewController(segue: UIStoryboardSegue) {
        
        // Check to see if we're coming back from saving tags. If not, exit with guard
        guard segue.identifier == "saveUnwindToAddEditDisc",
              let sourceViewController = segue.source as? SelectTagTableViewController else { return }
        
        tagsToAssign = sourceViewController.selectedTags
    }
}
