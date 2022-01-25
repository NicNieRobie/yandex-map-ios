//
//  MapPresenter.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 22.01.2022.
//

import Foundation
import CoreLocation
import YandexMapsMobile

// MARK: - MapPresenterInputLogic

/// _MapPresenterInputLogic_ is a protocol for map interactor output presenter behaviour.
protocol MapPresenterInputLogic: MapInteractorOutputLogic { }

// MARK: - MapPresenterOutputLogic

/// _MapPresenterOutputLogic_ is a protocol for map presenter output behaviour.
protocol MapPresenterOutputLogic {
    /// Displays the given route is it's a driving, bycicle or walking route with given endpoints.
    ///
    /// - parameter route: A driving, bycicle or walking route.
    /// - parameter endpoints: The route's endpoints.
    func displayRoute(_ route: NSObject, endpoints: [YMKPoint])
    /// Displays a routing error.
    func displayRoutingError()
}

// MARK: - MapPresenter

/// _MapPresenter_ is a default maps presenter class responsible
///   for handling output presentation calls from the interactor.
final class MapPresenter {
    // Presenter output.
    var output: MapPresenterOutputLogic?
    // Driving session instance used to build driving routes.
    var drivingSession: YMKDrivingSession?
    // Bycicle session instance used to build bycicle routes.
    var bycicleSession: YMKBicycleSession?
    // Masstransit session instance used to build pedestrian routes.
    var pedestrianSession: YMKMasstransitSession?
    // Endpoint of the built route.
    var routeEndpoints: [YMKPoint] = []
    
    // MARK: - Initializers
    
    /// Initializes a newly allocated _MapsPresenter_ instance with given output object.
    ///
    /// - parameter output: Presenter output logic that handles display calls.
    init(_ output: MapPresenterOutputLogic) {
        self.output = output
    }
}

// MARK: - MapPresenterInputLogic extension

extension MapPresenter: MapPresenterInputLogic {
    /// Presents a routing error.
    func presentRoutingError() {
        output?.displayRoutingError()
    }
    
    /// Builds and presents a route based on the coordinates of the endpoints and the transport type.
    ///
    /// - parameter coordinates: Coordinates of route's endpoints.
    /// - parameter transportType: Type of transport used.
    func presentRoute(coordinates: [YMKPoint], transportType: TransportType) {
        // Clear previous route.
        routeEndpoints.removeAll()
        
        if coordinates.count != 2 {
            presentRoutingError()
        }
        
        routeEndpoints = coordinates
        
        // Creating request points for the coordinates.
        let requestPoints : [YMKRequestPoint] = [
            YMKRequestPoint(point: coordinates[0], type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: coordinates[1], type: .waypoint, pointContext: nil),
        ]
        
        // Iterating over possible transport types.
        switch transportType {
        case .car:
            // If a route must be built for a car.
            
            // Car route request response handler.
            let responseHandler = {(routesResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
                if let routes = routesResponse, let route = routes.first {
                    self.output?.displayRoute(route, endpoints: self.routeEndpoints)
                } else {
                    self.output?.displayRoutingError()
                }
            }
            
            // Requesting a route from a new router.
            let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
            drivingSession = drivingRouter.requestRoutes(
                with: requestPoints,
                drivingOptions: YMKDrivingDrivingOptions(),
                vehicleOptions: YMKDrivingVehicleOptions(),
                routeHandler: responseHandler
            )
        case .bycicle:
            // If a route must be built for a bycicle.
            
            // Bycicle route request response handler.
            let responseHandler = {(routesResponse: [YMKBicycleRoute]?, error: Error?) -> Void in
                if let routes = routesResponse, let route = routes.first {
                    self.output?.displayRoute(route, endpoints: self.routeEndpoints)
                } else {
                    self.output?.displayRoutingError()
                }
            }
            
            // Requesting a route from a new router.
            let bycicleRouter = YMKTransport.sharedInstance().createBicycleRouter()
            bycicleSession = bycicleRouter.requestRoutes(
                with: requestPoints,
                routeListener: responseHandler
            )
        case .pedestrian:
            // If a route must be built for a pedestrian.
            
            // Pedestrian route request response handler.
            let responseHandler = {(routesResponse: [YMKMasstransitRoute]?, error: Error?) -> Void in
                if let routes = routesResponse, let route = routes.first {
                    self.output?.displayRoute(route, endpoints: self.routeEndpoints)
                } else {
                    self.output?.displayRoutingError()
                }
            }
            
            // Requesting a route from a new router.
            let pedRouter = YMKTransport.sharedInstance().createPedestrianRouter()
            pedestrianSession = pedRouter.requestRoutes(
                with: requestPoints,
                timeOptions: YMKTimeOptions(),
                routeHandler: responseHandler
            )
        }
    }
}
