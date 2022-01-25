//
//  MapViewController.swift
//  vmpendischukPW7
//
//  Created by Vladislav on 21.01.2022.
//

import UIKit
import MapKit
import CoreLocation
import YandexMapsMobile

// MARK: - MapViewControllerOutputLogic

/// _MapViewControllerInputLogic_ is a protocol for the map presenter output behaviour.
protocol MapViewControllerInputLogic: MapPresenterOutputLogic { }

/// _MapViewControllerOutputLogic_ is a protocol for the map view controller output behaviour.
protocol MapViewControllerOutputLogic {
    /// Builds the shortest route between two given addresses if possible.
    ///
    /// - parameter departureAddress: Address of the point of departure.
    /// - parameter destinationAddress: Address of the destination point.
    /// - parameter region: _YMKVisibleRegion_ instance denoting the priority region for coordinate search.
    /// - parameter transportType: _TransportType_ value denoting the type of transport for which
    ///                            the route is to be built.
    func buildRouteBetween(departureAddress: String, destinationAddress: String, region: YMKVisibleRegion, transportType: TransportType)
}

// MARK: - MapViewController

/// _MapViewController_ is a view controller responsible for displaying a map and controls for interaction.
class MapViewController: UIViewController {
    
    // MARK: - Views and variables initialization
    
    // Yandex Maps Mobile map view.
    private let yandexMapView: YMKMapView = {
        let ymv = YMKMapView()
        ymv.translatesAutoresizingMaskIntoConstraints = false
        return ymv
    }()
    // Text field for departure location input.
    private let startLocationField: UITextField = {
        let control = UITextField()
        // Text field appearance setup.
        control.backgroundColor = .clear
        control.textColor = .white
        control.placeholder = "From"
        control.clipsToBounds = false
        control.layer.cornerRadius = 5
        control.translatesAutoresizingMaskIntoConstraints = false
        control.font = .systemFont(ofSize: 15)
        control.borderStyle = .none
        control.contentVerticalAlignment = .center
        
        // Text field left padding setup.
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        control.leftView = paddingView
        control.leftViewMode = .always
        
        // Text field behaviour and interaction setup.
        control.autocorrectionType = .yes
        control.keyboardType = .default
        control.returnKeyType = .done
        control.clearButtonMode = .whileEditing
        
        return control
    }()
    // Text field for destination location input.
    private let endLocationField: UITextField = {
        let control = UITextField()
        // Text field appearance setup.
        control.backgroundColor = .clear
        control.textColor = .white
        control.placeholder = "To"
        control.clipsToBounds = false
        control.layer.cornerRadius = 5
        control.translatesAutoresizingMaskIntoConstraints = false
        control.font = .systemFont(ofSize: 15)
        control.borderStyle = .none
        control.contentVerticalAlignment = .center
        
        // Text field left padding setup.
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        control.leftView = paddingView
        control.leftViewMode = .always
        
        // Text field behaviour and interaction setup.
        control.autocorrectionType = .yes
        control.keyboardType = .default
        control.returnKeyType = .done
        control.clearButtonMode = .whileEditing
        
        return control
    }()
    // Container for the bottom panel stack view.
    private let bottomStackContainer: UIView = {
        let view = UIView()
        // Background blur setup.
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    // Bottom panel buttons stack view.
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        return stackView
    }()
    // Bottom panel stack view.
    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    // Map zoom controls stack view containner.
    private let zoomStackContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Background blur setup.
        view.backgroundColor = .clear
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        return view
    }()
    // Map zoom controls stack view.
    private let zoomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    // Route endpoints searchh text fields stack view.
    private let textFieldsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    // Text label for displaying the routing error.
    private let errorTextLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "Could not build the route"
        label.textColor = .red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Table used to display endpoints serach suggestions.
    private let suggestionTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        
        // Background blur setup.
        table.backgroundColor = .clear
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        table.layer.cornerRadius = 20
        table.clipsToBounds = true
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        table.backgroundView = blurEffectView
        
        table.register(SuggestionTableCell.self, forCellReuseIdentifier: "suggestCell")
        return table
    }()
    // Transport type selection control.
    private let transportTypeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [UIImage(named: "Car")!, UIImage(named: "Bycicle")!, UIImage(named: "Pedestrian")!])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.layer.backgroundColor = UIColor.clear.cgColor
        control.selectedSegmentTintColor = UIColor(red: 0, green: 0.83575, blue: 0.83575, alpha: 1)
        control.selectedSegmentIndex = 0
        control.subviews.flatMap{$0.subviews}.forEach { subview in
            if let imageView = subview as? UIImageView, let image = imageView.image, image.size.width > 5 {
                imageView.contentMode = .scaleAspectFit
            }
        }
        control.clipsToBounds = true
        return control
    }()
    // Map directional compass view.
    private let compassView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "CardinalPoint")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor(red: 0, green: 0.83, blue: 0.83, alpha: 1).cgColor
        imageView.layer.shadowRadius = 3
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageView.layer.masksToBounds = false
        return imageView
    }()
    // Increase map zoom button.
    private let zoomPlusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.contentMode = .scaleAspectFit
        return button
    }()
    // Decrease map zoom button.
    private let zoomMinusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Minus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.contentMode = .scaleAspectFit
        return button
    }()
    // Route details view.
    private let routeDetailsView = RouteDetailsView()
    // Route build button.
    private let goButton = CustomButton(color: UIColor(red: 0, green: 0.83575, blue: 0.83575, alpha: 1), text: "Go", withGlow: true)
    // Route reset button.
    private let resetButton = CustomButton(color: .white, text: "Reset", withGlow: false)
    // Endpoint addresses.
    private var departureFrom: String = ""
    private var destination: String = ""
    // Search suggestions list.
    var suggestResults: [YMKSuggestItem] = []
    // Seach manager used for providing search suggestions.
    let searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    // Search suggest session.
    var suggestSession: YMKSearchSuggestSession!
    // THe map's user location layer.
    var userLocationLayer: YMKUserLocationLayer!
    // A Boolean value denoting that the departure point address
    //   is the one that is being currently edited.
    var departureEdited: Bool = false
    // A Boolean value denoting that the destination point address
    //   is the one that is being currently edited.
    var destinationEdited: Bool = false
    // Map interactor.
    var output: MapViewControllerOutputLogic!

    // MARK: - Initializers
    
    /// Initializes a _MapViewController_ instance with given configurator.
    ///
    /// - parameter configurator: _MapViewController_ VIP pathways configurator.
    ///
    /// - returns: _MapViewController_ instance.
    required init(configurator: MapConfigurator = MapConfigurator.shared) {
        super.init(nibName: nil, bundle: nil)
        configure(configurator: configurator)
    }
    
    /// Initializes a _MapViewController_ instance with given coder.
    ///
    /// - parameter configurator: Coder.
    ///
    /// - returns: _MapViewController_ instance.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(configurator: MapConfigurator.shared)
    }
    
    // MARK: - Configuration
    
    /// Configures the _MapViewController_ with supplied configurator's settings.
    ///
    /// - parameter configurator: _MapViewController_ VIP pathways configurator.
    private func configure(configurator: MapConfigurator = MapConfigurator.shared) {
        configurator.configure(self)
    }
    
    // MARK: - Lifecycle
    
    /// On view load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Switch to dark theme.
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        }
        
        // Resiging the keyboard and the suggestion table on tap.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        suggestSession = searchManager.createSuggestSession()
        
        // Initializing the map.
        yandexMapView.mapWindow.map.isNightModeEnabled = true
        yandexMapView.mapWindow.map.isRotateGesturesEnabled = true
        yandexMapView.mapWindow.map.addCameraListener(with: self)
        
        // Initializing the user location layer.
        let scale = UIScreen.main.scale
        let mapKit = YMKMapKit.sharedInstance()
        userLocationLayer = mapKit.createUserLocationLayer(with: yandexMapView.mapWindow)

        // User location layer settings.
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
        userLocationLayer.isAutoZoomEnabled = false
        userLocationLayer.setAnchorWithAnchorNormal(
            CGPoint(x: 0.5 * self.view.frame.size.width * scale, y: 0.5 * self.view.frame.size.height * scale),
            anchorCourse: CGPoint(x: 0.5 * self.view.frame.size.width * scale, y: 0.83 * self.view.frame.size.height * scale))
        userLocationLayer.setObjectListenerWith(self)
        
        // Moving camera to the user's position.
        let cameraPos = userLocationLayer.cameraPosition()
        yandexMapView.mapWindow.map.move(with: YMKCameraPosition(target: cameraPos?.target ?? YMKPoint(latitude: 0, longitude: 0), zoom: 14, azimuth: 0, tilt: 0))
        
        // Adding event handlers.
        goButton.addTarget(self, action: #selector(self.goButtonPressed), for: .touchDown)
        resetButton.addTarget(self, action: #selector(self.resetButtonPressed), for: .touchDown)
        zoomPlusButton.addTarget(self, action: #selector(self.zoomPlusPressed), for: .touchDown)
        zoomMinusButton.addTarget(self, action: #selector(self.zoomMinusPressed), for: .touchDown)
        startLocationField.addTarget(self, action: #selector(self.startLocationEdited), for: .editingDidBegin)
        endLocationField.addTarget(self, action: #selector(self.endLocationEdited), for: .editingDidBegin)
        startLocationField.addTarget(self, action: #selector(self.locationQueryChanged(_:)), for: .editingChanged)
        endLocationField.addTarget(self, action: #selector(self.locationQueryChanged(_:)), for: .editingChanged)
        transportTypeControl.addTarget(self, action: #selector(self.transportTypeChanged), for: .valueChanged)
        
        // Suggestion table settings.
        suggestionTable.dataSource = self
        suggestionTable.delegate = self
        
        // Adding camera listener to reset to user location anchor.
        yandexMapView.mapWindow.map.addCameraListener(with: self)
        
        configureUI()
    }
    
    // MARK: - Event handlers
    
    /// On zoom increase button press.
    @objc func zoomPlusPressed() {
        let map = yandexMapView.mapWindow.map
        if (map.cameraPosition.zoom != 16) {
            // If the zoom isn't too big already - increment the zoom value.
            let prevPos = map.cameraPosition
            map.move(with: YMKCameraPosition(target: prevPos.target, zoom: prevPos.zoom + 1, azimuth: prevPos.azimuth, tilt: prevPos.tilt), animationType: YMKAnimation(type: .smooth, duration: 1))
        }
    }
    
    /// On zoom decrease button press.
    @objc func zoomMinusPressed() {
        let map = yandexMapView.mapWindow.map
        if (map.cameraPosition.zoom != 0) {
            // If the zoom isn't zero already - decrement the zoom value.
            let prevPos = map.cameraPosition
            map.move(with: YMKCameraPosition(target: prevPos.target, zoom: prevPos.zoom - 1, azimuth: prevPos.azimuth, tilt: prevPos.tilt), animationType: YMKAnimation(type: .smooth, duration: 1))
        }
    }
    
    /// On transport type change in the transport type segmented control.
    @objc func transportTypeChanged() {
        // Hiding the curret route's details.
        routeDetailsView.isHidden = true
        if (!departureFrom.isEmpty && !destination.isEmpty) {
            // If the endpoints are set - try to build a new route.
            output.buildRouteBetween(departureAddress: departureFrom, destinationAddress: destination, region: self.yandexMapView.mapWindow.map.visibleRegion, transportType: TransportType(rawValue: transportTypeControl.selectedSegmentIndex) ?? .car)
        }
    }
    
    /// On departure point address editing start.
    @objc func startLocationEdited() {
        // Setting the flags for the suggestion table delegate.
        departureEdited = true
        destinationEdited = false
        
        // Showing the suggestion table.
        suggestionTable.isHidden = false
        
        // Running the suggestion search request.
        locationQueryChanged(startLocationField)
    }
    
    /// On destination point editing start.
    @objc func endLocationEdited() {
        // Setting the flags for the suggestion table delegate.
        destinationEdited = true
        departureEdited = false
        
        // Showing the suggestion table.
        suggestionTable.isHidden = false
        
        // Running the suggestion search request.
        locationQueryChanged(endLocationField)
    }
    
    /// On endpoint address change.
    @objc func locationQueryChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        
        // Suggestion search request response handler.
        let suggestHandler = {(response: [YMKSuggestItem]?, error: Error?) -> Void in
            if let items = response {
                self.onSuggestResponse(items)
            }
        }
        
        // Using the user location if availiable or camera focus point otherwise.
        let userPosition = userLocationLayer.cameraPosition()?.target ?? YMKPoint(latitude: 0, longitude: 0)
        
        // Running the suggestions search.
        suggestSession.suggest(
            withText: text,
            window: YMKBoundingBox(
                southWest: YMKPoint(latitude: userPosition.latitude + 0.5, longitude: userPosition.longitude + 0.5),
                northEast: YMKPoint(latitude: userPosition.latitude - 0.5, longitude: userPosition.longitude - 0.5)),
            suggestOptions: YMKSuggestOptions(),
            responseHandler: suggestHandler)
    }
    
    /// On suggestion search being successful.
    func onSuggestResponse(_ items: [YMKSuggestItem]) {
        // Loading data into the suggestion table.
        suggestResults = items
        suggestionTable.reloadData()
    }
    
    /// On click outside the text fields and the suggestion table.
    @objc func dismissKeyboard() {
        // Dismissing the keyboard and the suggestion table.
        startLocationField.resignFirstResponder()
        endLocationField.resignFirstResponder()
        suggestionTable.isHidden = true
    }
    
    /// On reset button tap.
    @objc func resetButtonPressed() {
        // Resetting all settings and the suggestion table and clearing the map.
        startLocationField.text = ""
        endLocationField.text = ""
        departureFrom = ""
        destination = ""
        resetButton.isEnabled = false
        goButton.isEnabled = false
        errorTextLabel.isHidden = true
        destinationEdited = false
        departureEdited = false
        suggestResults.removeAll()
        suggestionTable.reloadData()
        suggestionTable.isHidden = true
        yandexMapView.mapWindow.map.mapObjects.clear()
        routeDetailsView.isHidden = true
    }
    
    /// On go button tap.
    @objc func goButtonPressed() {
        // Checking if the endpoint addresses were set.
        guard
            let source = startLocationField.text,
            let dest = endLocationField.text,
            source != dest
        else {
            return
        }
        
        departureFrom = source
        destination = dest
        
        errorTextLabel.isHidden = true
        routeDetailsView.isHidden = true
        
        // Sending the request to the interactor.
        output.buildRouteBetween(departureAddress: source, destinationAddress: dest, region: self.yandexMapView.mapWindow.map.visibleRegion, transportType: TransportType(rawValue: transportTypeControl.selectedSegmentIndex) ?? .car)
    }
    
    // MARK: - UI configuration
    
    /// Configures the map view conntroller's UI.
    private func configureUI() {
        // Attaching the map.
        self.view.addSubview(yandexMapView)
        yandexMapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        yandexMapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        yandexMapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        yandexMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // Attaching the bottom panel with the transport type control and route controls.
        self.view.addSubview(bottomStackContainer)
        bottomStackContainer.addSubview(bottomStackView)
        bottomStackContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        bottomStackContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        bottomStackContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        bottomStackView.topAnchor.constraint(equalTo: bottomStackContainer.topAnchor).isActive = true
        bottomStackView.bottomAnchor.constraint(equalTo: bottomStackContainer.bottomAnchor).isActive = true
        bottomStackView.leadingAnchor.constraint(equalTo: bottomStackContainer.leadingAnchor).isActive = true
        bottomStackView.trailingAnchor.constraint(equalTo: bottomStackContainer.trailingAnchor).isActive = true
        bottomStackView.addArrangedSubview(transportTypeControl)
        bottomStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: bottomStackView.leadingAnchor, constant: 50).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: bottomStackView.trailingAnchor, constant: -50).isActive = true
        transportTypeControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        transportTypeControl.leadingAnchor.constraint(equalTo: bottomStackContainer.leadingAnchor, constant: 0).isActive = true
        transportTypeControl.trailingAnchor.constraint(equalTo: bottomStackContainer.trailingAnchor, constant: -0).isActive = true
        [goButton, resetButton].forEach { button in
            button.heightAnchor.constraint(equalToConstant: 10).isActive = true
            buttonsStackView.addArrangedSubview(button)
            button.setTitleColor(.lightGray, for: .disabled)
            button.setTitleShadowColor(.clear, for: .disabled)
            button.isEnabled = false
        }
        
        // Attaching the map zoom controls container and setting its contents.
        self.view.addSubview(zoomStackContainer)
        zoomStackContainer.widthAnchor.constraint(equalToConstant: 50).isActive = true
        zoomStackContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        zoomStackContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        zoomStackContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        zoomStackContainer.addSubview(zoomStackView)
        zoomStackView.topAnchor.constraint(equalTo: zoomStackContainer.topAnchor).isActive = true
        zoomStackView.bottomAnchor.constraint(equalTo: zoomStackContainer.bottomAnchor).isActive = true
        zoomStackView.leadingAnchor.constraint(equalTo: zoomStackContainer.leadingAnchor).isActive = true
        zoomStackView.trailingAnchor.constraint(equalTo: zoomStackContainer.trailingAnchor).isActive = true
        zoomStackView.addArrangedSubview(zoomPlusButton)
        zoomStackView.addArrangedSubview(zoomMinusButton)
        
        // Attaching the error label.
        self.view.addSubview(errorTextLabel)
        errorTextLabel.bottomAnchor.constraint(equalTo: transportTypeControl.topAnchor, constant: -20).isActive = true
        errorTextLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60).isActive = true
        errorTextLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -60).isActive = true
        errorTextLabel.isHidden = true
        
        // Attaching the endpoint addresses stack view.
        self.view.addSubview(textFieldsStackView)
        textFieldsStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70).isActive = true
        textFieldsStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        textFieldsStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        // Configuring apperance of the text fields.
        [startLocationField, endLocationField].forEach { textField in
            let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
            let blurEffectView = UIVisualEffectView(effect: blur)
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            blurEffectView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            blurEffectView.layer.cornerRadius = 10
            blurEffectView.clipsToBounds = true
            
            blurEffectView.contentView.addSubview(textField)
            textField.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor).isActive = true
            textField.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor).isActive = true
            textField.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor).isActive = true
            textField.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor).isActive = true
            textField.delegate = self
            textFieldsStackView.addArrangedSubview(blurEffectView)
        }
        
        // Attaching the route details view.
        routeDetailsView.isHidden = true
        self.view.addSubview(routeDetailsView)
        routeDetailsView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        routeDetailsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        routeDetailsView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        routeDetailsView.bottomAnchor.constraint(equalTo: bottomStackContainer.topAnchor, constant: -20).isActive = true
        
        // Attaching the compass view.
        self.view.addSubview(compassView)
        compassView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        compassView.bottomAnchor.constraint(equalTo: bottomStackContainer.topAnchor, constant: -20).isActive = true
        compassView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        compassView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Attaching the suggestion table.
        self.view.addSubview(suggestionTable)
        suggestionTable.topAnchor.constraint(equalTo: endLocationField.bottomAnchor, constant: 40).isActive = true
        suggestionTable.bottomAnchor.constraint(equalTo: transportTypeControl.topAnchor, constant: -40).isActive = true
        suggestionTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        suggestionTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        suggestionTable.isHidden = true
    }
}

// MARK: - UITextFieldDelegate extension

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Resigning the keyboard on return.
        textField.resignFirstResponder()
        
        // Checking if the endpoints were set.
        guard let departurePoint = startLocationField.text, let destinationPoint = endLocationField.text
        else {
            goButton.isEnabled = false
            resetButton.isEnabled = false
            return true
        }
        
        // Building the route if endpoints were set.
        if (!departurePoint.isEmpty && !destinationPoint.isEmpty) {
            goButtonPressed()
        }
        
        return true
    }
    
    /// On text field editing ending.
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // Checking if the endpoints were set.
        guard let departurePoint = startLocationField.text, let destinationPoint = endLocationField.text
        else {
            goButton.isEnabled = false
            resetButton.isEnabled = false
            return
        }
        
        if (departurePoint != departureFrom || destinationPoint != destination) {
            // If endpoint addresses were changed during editing - clear the map.
            yandexMapView.mapWindow.map.mapObjects.clear()
            routeDetailsView.isHidden = true
            departureFrom = ""
            destination = ""
        }
        
        if (!departurePoint.isEmpty && !destinationPoint.isEmpty && departurePoint != destinationPoint) {
            // Activate the buttons if endpoints are set.
            goButton.isEnabled = true
            resetButton.isEnabled = true
        } else {
            // Deactivate the buttons otherwise.
            goButton.isEnabled = false
            if (!departurePoint.isEmpty || !destinationPoint.isEmpty) {
                resetButton.isEnabled = true
            } else {
                resetButton.isEnabled = false
            }
        }
    }
}

// MARK: - MapViewControllerInputLogic extension

extension MapViewController: MapViewControllerInputLogic {
    /// Displays the given route is it's a driving, bycicle or walking route with given endpoints.
    ///
    /// - parameter route: A driving, bycicle or walking route.
    /// - parameter endpoints: The route's endpoints.
    func displayRoute(_ route: NSObject, endpoints: [YMKPoint]) {
        if let route = route as? YMKDrivingRoute {
            // If the route is a driving route.
            // Moving the map to a new position.
            let boundingBox = YMKBoundingBox(southWest: endpoints[0], northEast: endpoints[1])
            let cameraPos = yandexMapView.mapWindow.map.cameraPosition(with: boundingBox)
            yandexMapView.mapWindow.map.move(with: YMKCameraPosition(target: cameraPos.target, zoom: cameraPos.zoom - 1, azimuth: cameraPos.azimuth, tilt: cameraPos.tilt), animationType: YMKAnimation(type: .smooth, duration: 1))
            
            // Clearing the map.
            let mapObjects = yandexMapView.mapWindow.map.mapObjects
            mapObjects.clear()
            
            // Initializing the jam style.
            let style = YMKJamStyle.createJamDarkStyle()
            
            // Adding the route.
            let routeLine = mapObjects.addColoredPolyline(with: route.geometry)
            
            // Stylizing the route polyline.
            YMKRouteHelper.updatePolyline(withPolyline: routeLine, route: route, style: style)
            routeLine.outlineWidth = 0
            routeLine.outlineColor = .clear
            
            // Display the route details.
            routeDetailsView.distanceLabel.text = route.metadata.weight.distance.text
            routeDetailsView.timeLabel.text = route.metadata.weight.timeWithTraffic.text
            routeDetailsView.isHidden = false
            
            // Display the endpoints as placemarks.
            endpoints.forEach { point in
                let placemark = mapObjects.addPlacemark(with: point)
                placemark.setIconWith(UIImage(named: "SearchResult")!)
            }
        } else if let route = route as? YMKBicycleRoute {
            // If the route is a bycicle route.
            // Moving the map to a new position.
            let boundingBox = YMKBoundingBox(southWest: endpoints[0], northEast: endpoints[1])
            let cameraPos = yandexMapView.mapWindow.map.cameraPosition(with: boundingBox)
            yandexMapView.mapWindow.map.move(with: YMKCameraPosition(target: cameraPos.target, zoom: cameraPos.zoom - 1, azimuth: cameraPos.azimuth, tilt: cameraPos.tilt), animationType: YMKAnimation(type: .smooth, duration: 1))
            
            // Clearing the map.
            let mapObjects = yandexMapView.mapWindow.map.mapObjects
            mapObjects.clear()
            
            // Adding the route.
            let routeLine = mapObjects.addPolyline(with: route.geometry)
            
            // Stylizing the route polyline.
            routeLine.strokeColor = UIColor(red: 0, green: 0.83, blue: 0.83, alpha: 1)
            
            // Display the route details.
            routeDetailsView.distanceLabel.text = route.weight.distance.text
            routeDetailsView.timeLabel.text = route.weight.time.text
            routeDetailsView.isHidden = false
            
            // Display the endpoints as placemarks.
            endpoints.forEach { point in
                let placemark = mapObjects.addPlacemark(with: point)
                placemark.setIconWith(UIImage(named: "SearchResult")!)
            }
        } else if let route = route as? YMKMasstransitRoute {
            // If the route is a walking route.
            // Moving the map to a new position.
            let boundingBox = YMKBoundingBox(southWest: endpoints[0], northEast: endpoints[1])
            let cameraPos = yandexMapView.mapWindow.map.cameraPosition(with: boundingBox)
            yandexMapView.mapWindow.map.move(with: YMKCameraPosition(target: cameraPos.target, zoom: cameraPos.zoom - 1, azimuth: cameraPos.azimuth, tilt: cameraPos.tilt), animationType: YMKAnimation(type: .smooth, duration: 1))
            
            // Clearing the map.
            let mapObjects = yandexMapView.mapWindow.map.mapObjects
            mapObjects.clear()
            
            // Adding the route.
            let routeLine = mapObjects.addPolyline(with: route.geometry)
            
            // Stylizing the route polyline.
            routeLine.strokeColor = UIColor(red: 0, green: 0.83, blue: 0.83, alpha: 1)
            
            // Display the route details.
            routeDetailsView.distanceLabel.text = route.metadata.weight.walkingDistance.text
            routeDetailsView.timeLabel.text = route.metadata.weight.time.text
            routeDetailsView.isHidden = false
            
            // Display the endpoints as placemarks.
            endpoints.forEach { point in
                let placemark = mapObjects.addPlacemark(with: point)
                placemark.setIconWith(UIImage(named: "SearchResult")!)
            }
        }
    }
    
    /// Displays a routing error.
    func displayRoutingError() {
        // Showing the error and resetting the route properties.
        errorTextLabel.isHidden = false
        departureFrom = ""
        destination = ""
    }
}

// MARK: - YMKUserLocationObjectListener extension

extension MapViewController: YMKUserLocationObjectListener {
    /// Called when the layer object is added. It is called once when the
    ///   user location icon appears the first time.
    func onObjectAdded(with view: YMKUserLocationView) {
        // Setting the user location layer anchor to display the user location.
        let scale = UIScreen.main.scale
        userLocationLayer.setAnchorWithAnchorNormal(
            CGPoint(x: 0.5 * self.view.frame.size.width * scale, y: 0.5 * self.view.frame.size.height * scale),
            anchorCourse: CGPoint(x: 0.5 * self.view.frame.size.width * scale, y: 0.83 * self.view.frame.size.height * scale))
        
        // Displaying the user location.
        view.arrow.setIconWith(UIImage(named:"UserIcon")!)
        let pinPlacemark = view.pin.useCompositeIcon()
        pinPlacemark.setIconWithName(
            "pin",
            image: UIImage(named: "UserIcon")!,
            style: YMKIconStyle (
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 1,
                flat: true,
                visible: true,
                scale: 1,
                tappableArea: nil
            )
        )

        // Stylising the accuracy circle.
        view.accuracyCircle.fillColor = UIColor(red: 0.00, green: 0.73, blue: 0.83, alpha: 0.4)
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) { }
    
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) { }
}

// MARK: - UITableViewDelegate extension

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Determine which text field is being currently edited and insert the chosen option into the text field.
        if (departureEdited) {
            if indexPath.row != 0 {
                startLocationField.text = suggestResults[indexPath.row - 1].displayText
            } else {
                startLocationField.text = "My location"
            }
            departureEdited = false
        } else if (destinationEdited) {
            if indexPath.row != 0 {
                endLocationField.text = suggestResults[indexPath.row - 1].displayText
            } else {
                endLocationField.text = "My location"
            }
            destinationEdited = false
        }
        
        // Reset the flags.
        departureEdited = false
        destinationEdited = false
        
        // Hide the suggestion table.
        suggestionTable.isHidden = true
        suggestResults.removeAll()
        
        // Check if both endpoints are not nil.
        guard let departurePoint = startLocationField.text, let destinationPoint = endLocationField.text else {
            goButton.isEnabled = false
            resetButton.isEnabled = false
            return
        }
        
        if (!departurePoint.isEmpty && !destinationPoint.isEmpty && departurePoint != destinationPoint) {
            // Activate the buttons if endpoints are set.
            goButton.isEnabled = true
            resetButton.isEnabled = true
        } else {
            // Deactivate the buttons otherwise.
            goButton.isEnabled = false
            if (!departurePoint.isEmpty || !destinationPoint.isEmpty) {
                resetButton.isEnabled = true
            } else {
                resetButton.isEnabled = false
            }
        }
    }
}

// MARK: - UITableViewDataSource extension

extension MapViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows in table equals to the amount of suggestions + user location.
        return suggestResults.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeueing a cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestCell", for: indexPath) as! SuggestionTableCell
        
        // Setting the displayed text.
        if (indexPath.row != 0) {
            cell.itemName.text = suggestResults[indexPath.row - 1].displayText
        } else {
            cell.itemName.text = "My location"
        }
        
        // Stylising the cell.
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Table header title.
        return "Suggestions"
    }
}

// MARK: - UIGestureRecognizerDelegate extension

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Getting the view that received the gesture.
        guard let view = touch.view else {
            return true
        }
        
        // Fire the event handler only if the view isn't in the suggestion table.
        return !(view.isDescendant(of: suggestionTable))
    }
}

// MARK: - YMKMapCameraListener extension

extension MapViewController: YMKMapCameraListener {
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
        // Rotating the compass according to the camera's azimuth so that the compass points to the north.
        compassView.transform = CGAffineTransform(rotationAngle: CGFloat(-cameraPosition.azimuth * Float.pi / 180))
        if finished {
            // Resetting the user location layer anchor on camera movement finish.
            userLocationLayer.resetAnchor()
        }
    }
}
