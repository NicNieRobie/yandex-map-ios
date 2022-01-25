//
//  MapConfigurator.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 22.01.2022.
//

import Foundation

// MARK: - MapConfigurator

/// _MapConfigurator_ is a default VIP cycle pathways configurator
///   for the _MapViewController_ instances.
final class MapConfigurator {
    /// Shared _MapConfigurator_ singleton instance.
    static let shared = MapConfigurator()
    
    /// Configures VIP cycle pathways for the given _MapViewController_ instance.
    ///
    /// - parameter viewController: Instance for configuration.
    func configure(_ viewController: MapViewController) {
        let presenter = MapPresenter(viewController)
        let interactor = MapInteractor(presenter)
        
        viewController.output = interactor
    }
}
