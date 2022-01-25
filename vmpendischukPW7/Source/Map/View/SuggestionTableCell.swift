//
//  SuggestionTableCell.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 22.01.2022.
//

import UIKit

// MARK: - SuggestionTableCell

/// _SuggestionTableCell_ is a class that represents a default cell of the suggestions table.
class SuggestionTableCell: UITableViewCell {
    // MARK: - Variables
    
    // Name of a item - display name of the suggestion.
    let itemName: UILabel = UILabel()

    // MARK: - Initializers
    
    /// Initializes and returns a newly allocated _SuggestionTableCell_ instance with given style and reuse identifier.
    ///
    /// - parameter style: Style of the cell.
    /// - parameter reuseIdentifier: Reuse identifier of the cell used in table views.
    ///
    /// - returns: _SuggestionTableCell_ instance.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    /// Initializes and returns a newly allocated _SuggestionTableCell_ instance with given coder.
    ///
    /// - parameter coder: An _NSCoder_ instance.
    ///
    /// - returns: _SuggestionTableCell_ instance.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - View setup
    
    /// View content and constraints setup.
    func setup() {
        // Content view constraints setup.
        self.contentView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Item name label setup.
        self.contentView.addSubview(itemName)
        itemName.textColor = .white
        itemName.translatesAutoresizingMaskIntoConstraints = false
        itemName.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        itemName.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        itemName.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        itemName.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
    }
}
