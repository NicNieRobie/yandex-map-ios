//
//  MapInteractor.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 21.01.2022.
//

import Foundation
import CoreLocation
import YandexMapsMobile

// MARK: - MapInteractorInputLogic

/// _MapInteractorInputLogic_ is a protocol for map interactor input behaviour.
protocol MapInteractorInputLogic: MapViewControllerOutputLogic { }

// MARK: - MapInteractorOutputLogic

/// _MapInteractorInputLogic_ is a protocol for map interactor output behaviour.
protocol MapInteractorOutputLogic {
    /// Presents a routing error.
    func presentRoutingError()
    /// Builds and presents a route based on the coordinates of the endpoints and the transport type.
    ///
    /// - parameter coordinates: Coordinates of route's endpoints.
    /// - parameter transportType: Type of transport used.
    func presentRoute(coordinates: [YMKPoint], transportType: TransportType)
}

// MARK: - MapInteractor

/// _MapInteractor_ is a default VIP interactor class responsible for map business logic.
final class MapInteractor: NSObject {
    // Interactor's output presenter.
    var output: MapInteractorOutputLogic?
    // Search manager used for endpoints search.
    var searchManager: YMKSearchManager?
    // First search session used for endpoints search.
    var firstSearchSession: YMKSearchSession?
    // Second search session used for endpoints search.
    var secondSearchSession: YMKSearchSession?
    // Point of departure.
    private var departureFrom: YMKPoint? {
        didSet {
            // Building the route if both endpoints have been set.
            if let departureFrom = departureFrom, let destination = destination {
                output?.presentRoute(coordinates: [departureFrom, destination], transportType: self.transportType)
            }
        }
    }
    // Point of destination.
    private var destination: YMKPoint? {
        didSet {
            // Building the route if both endpoints have been set.
            if let departureFrom = departureFrom, let destination = destination {
                output?.presentRoute(coordinates: [departureFrom, destination], transportType: self.transportType)
            }
        }
    }
    // Location manager used to receive user's location.
    private let locManager = CLLocationManager()
    // Type of the transport which the route must be built for.
    private var transportType: TransportType!
    // A Boolean value that denotes whether the point of departure is set to user's location.
    private var departureIsMyPos: Bool = false
    // A Boolean value that denotes whether the point of destination is set to user's location.
    private var destinationIsMyPos: Bool = false
    
    // MARK: - Initializers
    
    /// Initializes a newly allocated _MapInteractor_ instance with given output presenter.
    ///
    /// - parameter output: Interactor output presenter.
    ///
    /// - returns: _MapInteractor_ instance.
    init(_ output: MapInteractorOutputLogic) {
        self.output = output
        searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
        locManager.requestWhenInUseAuthorization()
    }
    
    /// Gets a _YMKPoint_ instance which denotes the search result's coordinates from given response.
    ///
    /// - parameter searchResponse: The search request response.
    ///
    /// - returns: A _YMKPoint_ instance if the search was successful and nil otherwise.
    func getPointFrom(_ searchResponse: YMKSearchResponse) -> YMKPoint? {
        if let searchResult = searchResponse.collection.children.first {
            if let point = searchResult.obj?.geometry.first?.point {
                return point
            }
        }
        
        return nil
    }
}

// MARK: - MapInteractorInputLogic extension

extension MapInteractor: MapInteractorInputLogic {
    /// Builds the shortest route between two given addresses if possible.
    ///
    /// - parameter departureAddress: Address of the point of departure.
    /// - parameter destinationAddress: Address of the destination point.
    /// - parameter region: _YMKVisibleRegion_ instance denoting the priority region for coordinate search.
    /// - parameter transportType: _TransportType_ value denoting the type of transport for which
    ///                            the route is to be built.
    func buildRouteBetween(departureAddress: String, destinationAddress: String, region: YMKVisibleRegion, transportType: TransportType) {
        // Resetting the route.
        departureFrom = nil
        destination = nil
        departureIsMyPos = false
        destinationIsMyPos = false
        
        // Setting the transport type.
        self.transportType = transportType
        
        if (departureAddress == "My location") {
            // If the departure point is set to user location - try to fetch user location.
            if CLLocationManager.locationServicesEnabled() {
                locManager.delegate = self
                locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locManager.startUpdatingLocation()
                departureIsMyPos = true
            } else {
                output?.presentRoutingError()
            }
        } else {
            // Otherwise - use the search manager to find the coordinates.
            
            // Search response handler.
            let depSearchResponseHandler = {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
                if let response = searchResponse {
                    self.departureFrom = self.getPointFrom(response)
                } else {
                    self.output?.presentRoutingError()
                }
            }
            
            // Submitting the search query.
            firstSearchSession = searchManager!.submit(
                withText: departureAddress,
                geometry: YMKVisibleRegionUtils.toPolygon(with: region),
                searchOptions: YMKSearchOptions(),
                responseHandler: depSearchResponseHandler)
        }
        
        if (destinationAddress == "My location") {
            // If the destination point is set to user location - try to fetch user location.
            if CLLocationManager.locationServicesEnabled() {
                locManager.delegate = self
                locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locManager.startUpdatingLocation()
                destinationIsMyPos = true
            } else {
                output?.presentRoutingError()
            }
        } else {
            // Otherwise - use the search manager to find the coordinates.
            
            // Search response handler.
            let destSearchResponseHandler = {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
                if let response = searchResponse {
                    self.destination = self.getPointFrom(response)
                } else {
                    self.output?.presentRoutingError()
                }
            }
            
            // Submitting the search query.
            secondSearchSession = searchManager!.submit(
                withText: destinationAddress,
                geometry: YMKVisibleRegionUtils.toPolygon(with: region),
                searchOptions: YMKSearchOptions(),
                responseHandler: destSearchResponseHandler)
        }
    }
}

// MARK: - CLLocationManagerDelegate extension

extension MapInteractor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // On user location fetch.
        if departureIsMyPos {
            // Set the departure point coordinates if the departure point is set to user location.
            departureFrom = YMKPoint(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        } else if destinationIsMyPos {
            // Set the destination point coordinates if the destination point is set to user location.
            destination = YMKPoint(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        }
        // Disable location updates.
        locManager.stopUpdatingLocation()
    }
}
