//
//  FilterView.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 10/4/22.
//

import UIKit

// This class...
class FilterView: UIView {
    
    var standardFilter: InventoryFilter?
    var tagFilter: String?
    weak var delegate: RemoveInventoryFilterDelegate?
    
    let newFilterButtonView = UIView()
    let newFilterButton = RemoveFilterButton(type: .system)
    
    // TODO: Determine if there is a need for this init - research a better way to do what we're trying to do with these inits
    init() {
        super.init(frame: CGRect())
    }
    
    convenience init(standardFilter: InventoryFilter) {
        self.init()
        self.standardFilter = standardFilter
        createView()
    }
    
    convenience init(tagFilter: String) {
        self.init()
        self.tagFilter = tagFilter
        createView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: Rename variables with more appropriate names
    func createView() {
        
        // Create filter view
        backgroundColor = (standardFilter != nil ? .white : UIColor(red: 161/255, green: 1, blue: 139/255, alpha: 1))
        layer.cornerRadius = 10
        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        
        // Create filter label
        let newFilterLabel = UILabel()
        newFilterLabel.attributedText = NSAttributedString(string: (standardFilter != nil ? standardFilter?.rawValue : tagFilter)!, attributes: [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 14) ?? .preferredFont(forTextStyle: .body)])
        newFilterLabel.textColor = .black
        newFilterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create remove filter button
        newFilterButton.translatesAutoresizingMaskIntoConstraints = false
        newFilterButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        newFilterButton.tintColor = .black
        newFilterButton.addTarget(self, action: #selector(removeFilterButtonPressed(_:)), for: .touchUpInside)
        
        // Create large filter button parent view to contain extended button hitbox
        newFilterButtonView.backgroundColor = .clear
        newFilterButtonView.translatesAutoresizingMaskIntoConstraints = false
        //newFilterButtonView.alpha = 0.5
        newFilterButtonView.addSubview(newFilterButton)
        
        // Add label and button to filter view
        addSubview(newFilterLabel)
        addSubview(newFilterButtonView)
        
        // Filter label constraints
        newFilterLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        newFilterLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        newFilterLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        newFilterLabel.rightAnchor.constraint(equalTo: newFilterButton.leftAnchor, constant: -5).isActive = true
        
        // Filter button view constraints
        newFilterButtonView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        newFilterButtonView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        newFilterButtonView.centerXAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        newFilterButtonView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        // Filter button view constraints
        newFilterButton.widthAnchor.constraint(equalToConstant: 11).isActive = true
        newFilterButton.heightAnchor.constraint(equalToConstant: 11).isActive = true
        newFilterButton.centerYAnchor.constraint(equalTo: newFilterButtonView.centerYAnchor).isActive = true
        newFilterButton.centerXAnchor.constraint(equalTo: newFilterButtonView.centerXAnchor).isActive = true
    }
    
    // Remove the pressed filter
    @objc func removeFilterButtonPressed(_ sender: UIButton) {
        print("remove filter button pressed")
        delegate?.removeFilter(self)
    }
    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let convertedPoint = newFilterButtonView.convert(point, from: self)
//        return newFilterButton.point(inside: convertedPoint, with: event)
//    }
}
