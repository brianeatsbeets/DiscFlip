//
//  AddEditCashTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/6/22.
//

import UIKit

// This class/table view controller handles the creating of new cash objects and editing of existing cash objects
class AddEditCashTableViewController: UITableViewController {
    
    var cash: Cash?
    
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var memoTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // Initialize with cash data
    init?(coder: NSCoder, cash: Cash?) {
        self.cash = cash
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        
        updateSaveButtonState()
    }
    
    // Fill in existing cash data (if any) and update view title
    func updateUI() {
        if let cash = cash {
            title = "Update Cash"
            amountTextField.text = String(cash.amount)
            memoTextField.text = cash.memo
        } else {
            title = "Add Cash"
        }
    }
    
    // Enable and disable the save button based on text field validation
    func updateSaveButtonState() {
        
        // Check that both fields have text
        // Check that amountTextField can be cast as an Int
        if let amountText = amountTextField.text,
           let memoText = memoTextField.text,
           Int(amountText) != nil && !memoText.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // Trigger the save button state update when text is edited
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    
    @IBAction func amountTextEditingChanged(_ sender: UITextField) {
        if let amountText = sender.text,
           Int(amountText) == nil {
            sender.backgroundColor = UIColor(red: 1, green: 215/255, blue: 215/255, alpha: 1)
            
            if let section = tableView.headerView(forSection: 0) {
                var content = section.defaultContentConfiguration()
                content.text = "Text 1"
                content.secondaryText = "Text 2"
                section.contentConfiguration = content
            }
            
        } else {
            sender.backgroundColor = UIColor.systemBackground
        }
    }
    
    
    //MARK: - Navigation
    
    // Compile the cash data for sending back to the cash table view controller
    @IBAction override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Make sure we're saving and not cancelling
        guard segue.identifier == "cashSaveUnwind" else { return }
        
        let amount = Int(amountTextField.text!) ?? 0
        let memo = memoTextField.text!
        
        cash = Cash(amount: amount, memo: memo)
    }
}
