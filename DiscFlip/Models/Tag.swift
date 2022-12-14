//
//  Tag.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 10/7/22.
//

// MARK: - Imported libraries

import Foundation

// This class represents a tag, which can be used to group and filter discs
struct Tag: Codable, CustomStringConvertible, Hashable {
    
    // MARK: - Class properties

    let id: UUID
    var title: String {
        didSet {
            description = "Tag: \(title)"
        }
    }
    
    // Property required by CustomStringConvertible protocol
    var description: String
    
    // MARK: - Initializers
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.description = "Tag: \(title)"
    }
    
    // MARK: - Utility functions
    
    // Save the updated tags
    static func saveTagsToDisk(_ tagsList: [Tag]) {
        // Create path to Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("tags") . appendingPathExtension("plist")
        
        // Encode data
        let propertyListEncoder = PropertyListEncoder()
        if let encodedTags = try? propertyListEncoder.encode(tagsList) {
            // Save tags
            try? encodedTags.write(to: archiveURL, options: .noFileProtection)
        }
    }
}
