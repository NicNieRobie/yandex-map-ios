//
//  CustomButton.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 21.01.2022.
//

import UIKit

// MARK: - CustomButton

/// _CustomButton_ is a class that represents a custom background-less button.
class CustomButton: UIButton {
    // MARK: - Variables
    
    // Button label's color.
    private var color: UIColor?
    // Button label's text.
    private var buttonText: String = ""
    // A Boolean value that determines whether the button will have
    //   a glow (shadow) of the same color as the supplied label color.
    private var withGlow: Bool = false
    // A Boolean value that determines if the button is enabled for interaction.
    override public var isEnabled: Bool {
        didSet {
            if withGlow {
                if self.isEnabled {
                    // If the button was enabled - display the glow.
                    self.titleLabel?.layer.shadowColor = color?.cgColor
                } else {
                    // If the button was disabled - hide the glow.
                    self.titleLabel?.layer.shadowColor = UIColor.clear.cgColor
                }
            }
        }
    }
    
    // MARK: - Initializers
    
    /// Initializes and returns a newly allocated _CustomButton_ instance with specified visual settings.
    ///
    /// - parameter color: The button label's color.
    /// - parameter text: The button label's text.
    /// - parameter withGlow: A Boolean value that determines whether the button will have
    ///                       a glow (shadow) of the same color as the supplied label color.
    ///
    /// - returns: _CustomButton_ instance.
    public convenience init(color: UIColor, text: String, withGlow: Bool) {
        self.init()
        
        // Initialing settings.
        self.color = color
        self.buttonText = text
        self.withGlow = withGlow
        
        setup()
    }
    
    // MARK: - View setup
    
    /// View content and constraints setup.
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        
        // Setting the button title.
        self.setTitle(buttonText, for: .normal)
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        // Configuring and displaying the glow.
        if (withGlow) {
            self.titleLabel?.shadowOffset = CGSize(width: 0, height: 0)
            self.titleLabel?.layer.shadowColor = color?.cgColor
            self.titleLabel?.layer.masksToBounds = false
            self.titleLabel?.layer.shouldRasterize = true
            self.titleLabel?.layer.shadowRadius = 8
            self.titleLabel?.layer.shadowOpacity = 0.8
        }
    }
}
