//
//  AddEditCashTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 9/6/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Main class

// This class/table view controller handles the creating of new cash objects and editing of existing cash objects
class AddEditCashTableViewController: UITableViewController {
    
    // MARK: - Class properties
    
    var cash: Cash?
    
    // IBOutlets
    
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var memoTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // MARK: - Initializers
    
    // Initialize with cash data
    init?(coder: NSCoder, cash: Cash?) {
        self.cash = cash
        super.init(coder: coder)
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        updateSaveButtonState()
        setPolarityKeyboardToolbar()
        
        // Create a gesture recognizer to dismiss the keyboard when an outside tap is registered
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountTextField.becomeFirstResponder()
    }
    
    // MARK: - Utility functions
    
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
    
    // Create and add a keyboard toolbar containing a +/- polarity toggle to amountTextField
    func setPolarityKeyboardToolbar() {
        //let polarityToolbar = UIToolbar()
        let polarityToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 35)) // Using initializer with frame silences some constraint warnings; toolbar is sized appropriately further down using .sizeToFit()
        let polarityButton = UIBarButtonItem(title: "+/-", style: .plain, target: self, action: #selector(polarityButtonTapped))
        
        polarityButton.tintColor = .label
        polarityButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .normal)
        
        let padding = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        polarityToolbar.items = [padding, polarityButton, padding]
        polarityToolbar.sizeToFit()
        
        amountTextField.inputAccessoryView = polarityToolbar
    }
    
    // Hide keyboard toolbar to create a less-visually-jittery transition when immediately transitioning to memo text field keyboard
    @IBAction func amountEditingEnded(_ sender: UITextField) {
        sender.inputAccessoryView?.isHidden = true
    }
    
    // Show keyboard toolbar when editing amount text field
    @IBAction func amountEditingBegan(_ sender: UITextField) {
        sender.inputAccessoryView?.isHidden = false
    }
    
    // Toggle the amountTextField text polarity
    @objc func polarityButtonTapped() {
        guard let currentText = amountTextField.text else { return }
        
        // If the text is negative, remove the first character
        if currentText.hasPrefix("-") {
            let offsetIndex = currentText.index(currentText.startIndex, offsetBy: 1)
            let substring = currentText[offsetIndex...]
            amountTextField.text = String(substring)
        }
        else { // Else, add a minus sign at the beginning
            amountTextField.text = "-" + currentText
        }
    }
    
    // Trigger the save button state update when text is edited
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func doneKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // Dismiss the keyboard when an outside tap is registered
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
