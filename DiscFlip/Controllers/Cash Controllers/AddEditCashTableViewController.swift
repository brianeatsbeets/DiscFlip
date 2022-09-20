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
        
        setPolarityKeyboardToolbar()
        
        // Create a gesture recognizer to dismiss the keyboard when an outside tap is registered
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        amountTextField.becomeFirstResponder()
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
    
    // Create and add a keyboard toolbar containing a +/- polarity toggle to amountTextField
    func setPolarityKeyboardToolbar() {
        let bar = UIToolbar()
        let polarityButton = UIBarButtonItem(title: "+/-", style: .plain, target: self, action: #selector(polarityButtonTapped))
        
        polarityButton.tintColor = .black
        polarityButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .normal)
        polarityButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .disabled)
        polarityButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .selected)
        polarityButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 17) ?? .preferredFont(forTextStyle: .body)], for: .highlighted)
        
        let padding = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [padding, polarityButton, padding]
        bar.sizeToFit()
        amountTextField.inputAccessoryView = bar
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
