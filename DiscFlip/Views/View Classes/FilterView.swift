//
//  FilterView.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 10/4/22.
//

// MARK: - Imported libraries

import UIKit

// MARK: - Protocols

protocol FilterPillViewRemoveButtonDelegate: AnyObject {
    func removeButtonPressed()
}

// MARK: - Main class

// This class/view presents a padded container view for an inventory filter view, which is needed to accomodate the UIButton subclass RemoveFilterButton and its increased hitbox size
class FilterContainerView: UIView {
    
    // MARK: - Class properties
    
    var tagFilter: Tag
    var pillView: FilterPillView
    weak var delegate: RemoveTagFilterDelegate?
    
    // MARK: - Initializers
    
    // Init with tag filter
    init(tagFilter: Tag) {
        self.tagFilter = tagFilter
        self.pillView = FilterPillView(tagFilter: tagFilter)
        super.init(frame: CGRect())
        createView()
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Utility functions
    
    // Create and customize the filter container view
    func createView() {
        
        // Customize filter container view
        backgroundColor = .clear
        
        // Customize filter pill view
        pillView.delegate = self
        pillView.backgroundColor = .white
        pillView.layer.cornerRadius = 10
        pillView.clipsToBounds = false
        pillView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add filter pill view to filter container view
        addSubview(pillView)
        
        // Filter pill view constraints
        pillView.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        pillView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -11).isActive = true
        pillView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        pillView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
}

// MARK: - Extensions

// This extension of FilterContainerView conforms to the FilterPillViewDelegate protocol in order to be notified by the FilterPilView subview when the remove filter button is pressed
extension FilterContainerView: FilterPillViewRemoveButtonDelegate {
    func removeButtonPressed() {
        delegate?.removeFilter(self)
    }
}

// MARK: - Other classes

// This class/view presents an inventory filter view
class FilterPillView: UIView {
    
    // MARK: - Class properties
    
    var tagFilter: Tag
    let removeFilterButton = RemoveFilterButton(type: .system)
    weak var delegate: FilterPillViewRemoveButtonDelegate?
    
    // MARK: - Initializers
    
    // Init with tag filter
    init(tagFilter: Tag) {
        self.tagFilter = tagFilter
        super.init(frame: CGRect())
        createView()
    }
    
    // Implement required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Utility functions
    
    // Create and customize the filter pill view
    func createView() {
        
        // Create and customize filter label
        let filterLabel = UILabel()
        filterLabel.attributedText = NSAttributedString(string: tagFilter.title, attributes: [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 14) ?? .preferredFont(forTextStyle: .body)])
        filterLabel.textColor = .black
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Customize remove filter button
        removeFilterButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        removeFilterButton.tintColor = .black
        removeFilterButton.addTarget(self, action: #selector(removeFilterButtonPressed(_:)), for: .touchUpInside)
        removeFilterButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add label and button to filter view
        addSubview(filterLabel)
        addSubview(removeFilterButton)
        
        // Filter label constraints
        filterLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        filterLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        filterLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        filterLabel.rightAnchor.constraint(equalTo: removeFilterButton.leftAnchor, constant: -5).isActive = true
        
        // Filter button constraints
        removeFilterButton.widthAnchor.constraint(equalToConstant: 11).isActive = true
        removeFilterButton.heightAnchor.constraint(equalToConstant: 11).isActive = true
        removeFilterButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        removeFilterButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
    }
    
    // Notify the filter container view that the remove filter button was pressed
    @objc func removeFilterButtonPressed(_ sender: UIButton) {
        delegate?.removeButtonPressed()
    }
    
    // Allow the remove filter button's enlargened hitbox to extend beyond this view's frame
    // Via Pete Smith from https://zendesk.engineering/ios-how-to-capture-touch-events-outside-uiview-bounds-bc74619707881
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let convertedPoint = removeFilterButton.convert(point, from: self)
        return removeFilterButton.point(inside: convertedPoint, with: event)
    }
}
