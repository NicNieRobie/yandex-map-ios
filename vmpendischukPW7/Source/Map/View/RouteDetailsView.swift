//
//  RouteDetailsView.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 24.01.2022.
//

import UIKit

// MARK: - RouteDetailsView

/// _RouteDetailsView_ is a class that represents a view for route details.
class RouteDetailsView: UIView {
    // MARK: - Variables
    // Stack view container for label stacking.
    public let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    // Label for route's distance.
    public let distanceLabel = UILabel()
    // Label for route journey time.
    public let timeLabel = UILabel()
    
    // MARK: - Initializers
    
    /// Initializes and returns a newly allocated _RouteDetailsView_ instance with given style and reuse identifier.
    ///
    /// - parameter frame: The frame rectangle for the view, measured in points.
    ///                    The origin of the frame is relative to the superview in which you plan to add it.
    ///                    This method uses the frame rectangle to set the center and bounds properties accordingly.
    ///
    /// - returns: _RouteDetailsView_ instance.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// Initializes and returns a newly allocated _RouteDetailsView_ instance with given coder.
    ///
    /// - parameter coder: An _NSCoder_ instance.
    ///
    /// - returns: _RouteDetailsView_ instance.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - View setup
    
    /// View content and constraints setup.
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        
        // Background blur setup.
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        // Stack view setup.
        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        // Labels setup.
        stackView.addArrangedSubview(distanceLabel)
        stackView.addArrangedSubview(timeLabel)
        distanceLabel.font = .boldSystemFont(ofSize: 13)
        timeLabel.font = .systemFont(ofSize: 11)
    }
}
