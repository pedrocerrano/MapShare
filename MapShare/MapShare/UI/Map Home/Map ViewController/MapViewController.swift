//
//  MapViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/25/23.
//

import UIKit
import MapKit
import CoreLocation
import CoreLocationUI

class MapViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sessionActivityIndicatorLabel: UILabel!
    @IBOutlet weak var membersInActiveSessionLabel: UILabel!
    @IBOutlet weak var membersInWaitingRoomLabel: UILabel!
    @IBOutlet weak var activeMembersStackView: UIStackView!
    @IBOutlet weak var waitingRoomStackView: UIStackView!
    @IBOutlet weak var travelMethodButton: UIButton!
    @IBOutlet weak var centerLocationButton: UIButton!
    @IBOutlet weak var centerRouteButton: UIButton!
    @IBOutlet weak var clearRouteAnnotationsButton: UIButton!
    @IBOutlet weak var refreshLocationButton: UIButton!
    
    
    // MARK: - Properties
    var mapViewModel: MapViewModel!
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewModel = MapViewModel(delegate: self)
        mapViewModel.locationManager.delegate = self
        setupNewSessionSheetController()
        registerMapAnnotations()
        addGesture()
        configureUI()
    }
    
    
    // MARK: - IB Actions
    @IBAction func travelMethodButtonTapped(_ sender: UIButton) {
        mapViewModel.toggleTravelMethod(for: sender)
    }
    
    @IBAction func centerLocationButtonTapped(_ sender: UIButton) {
        mapViewModel.resetZoomToCenterMembers(forMapView: mapView, centerLocationButton: centerLocationButton)
    }
    
    @IBAction func centerRouteButtonTapped(_ sender: UIButton) {
        mapViewModel.resetZoomToCenterRoute(forMapView: mapView, centerRouteButton: centerRouteButton)
    }
    
    @IBAction func clearRouteAnnotationsButtonTapped(_ sender: Any) {
        mapViewModel.clearRouteAnnotations(forMapView: mapView,
                                               centerRouteButton: centerRouteButton,
                                               clearRouteAnnotationsButton: clearRouteAnnotationsButton,
                                               travelMethodButton: travelMethodButton)
    }
    
    @IBAction func refreshLocationButtonTapped(_ sender: Any) {
        let memberAnnotations      = mapView.annotations.filter { ($0 is Member) }
        let memberAnnotationTitles = memberAnnotations.map { $0.title! }
        print("[BUTTON] MemberAnnotations Titles: \(memberAnnotationTitles)")
        print("[BUTTON] MemberAnnotations Count:  \(memberAnnotations.count)")
    }
    
    
    //MARK: - Functions
    func hideButtons(_ bool: Bool) {
        activeMembersStackView.isHidden = bool
        waitingRoomStackView.isHidden   = bool
        travelMethodButton.isHidden     = bool
        centerRouteButton.isHidden      = bool
        refreshLocationButton.isHidden  = bool
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton       = true
        clearRouteAnnotationsButton.isHidden = true
        hideButtons(true)
        [travelMethodButton, centerLocationButton, centerRouteButton].forEach { button in
            if let button { UIStyling.styleFilledButton(for: button, withColor: UIColor.dodgerBlue()) }
        }
        UIStyling.styleLabel(for: sessionActivityIndicatorLabel)
        UIStyling.styleFilledButton(for: clearRouteAnnotationsButton, withColor: .systemGray3)
        UIStyling.styleFilledButton(for: refreshLocationButton, withColor: UIColor.mapShareGreen())
        clearRouteAnnotationsButton.configuration?.baseForegroundColor = .label
    }
    
    private func setupNewSessionSheetController() {
        let storyboard = UIStoryboard(name: "NewSession", bundle: nil)
        guard let sheetController = storyboard.instantiateViewController(withIdentifier: "NewSessionVC") as? NewSessionViewController else { return }
        sheetController.isModalInPresentation = true
        sheetController.newSessionViewModel = NewSessionViewModel(mapDelegate: self)
        self.parent?.present(sheetController, animated: true, completion: nil)
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard let session = mapViewModel.mapShareSession else { return }
        if session.organizerDeviceID == Constants.Device.deviceID && session.routes.isEmpty {
            let tappedLocation     = gestureRecognizer.location(in: mapView)
            let tappedCoordinate   = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            let newRouteAnnotation = Route(coordinate: tappedCoordinate, title: nil, isShowingDirections: false, isDriving: true)
            mapViewModel.saveRouteToFirestore(newRoute: newRouteAnnotation)
            clearRouteAnnotationsButton.isHidden = false
            travelMethodButton.isHidden          = false
        } else {
            return
        }
    }
    
    private func getDirections(routeAnnotation: MKAnnotation, withTravelType travelType: MKDirectionsTransportType) {
        guard let activeMembers = mapViewModel.mapShareSession?.members.filter ({ $0.isActive }) else { return }
        for member in activeMembers {
            let location   = CLLocationCoordinate2D(latitude: member.coordinate.latitude, longitude: member.coordinate.longitude)
            let request    = mapViewModel.createDirectionsRequest(from: location, annotation: routeAnnotation, withTravelType: travelType)
            let directions = MKDirections(request: request)
            resetMapView(withNew: directions)
            directions.calculate { [weak self] response, error in
                if let error = error { print(error.localizedDescription) ; return }
                
                guard let response = response,
                      let self     = self
                else { return }
                
                for route in response.routes {
                    self.mapViewModel.updateMemberTravelTime(withMemberID: member.deviceID, withTravelTime: route.expectedTravelTime)
                    route.polyline.title = member.title
                    self.mapView.addOverlay(route.polyline)
                    self.mapViewModel.resetZoomForAllMembersRoutes(forMapView: mapView)
                }
            }
        }
    }
    
    func displayDirections(forSession session: Session, withTravelType travelType: MKDirectionsTransportType) {
        for newRouteAnnotation in session.routes {
            mapView.addAnnotation(newRouteAnnotation)
            print("[DISPLAY DIRECTIONS]: I added \(newRouteAnnotation.title ?? "ABC")")
            
            if newRouteAnnotation.isShowingDirections {
                getDirections(routeAnnotation: newRouteAnnotation, withTravelType: travelType)
            }
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        mapViewModel.directionsArray.append(directions)
        let _ = mapViewModel.directionsArray.map { $0.cancel() }
    }
} //: Class


//MARK: - EXT: LocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch mapViewModel.locationManager.authorizationStatus {
        case .notDetermined:
            mapViewModel.locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            NotificationCenter.default.post(name: Constants.Notifications.locationAccessNeeded, object: nil)
            break
        case .authorizedWhenInUse:
            mapViewModel.startTrackingLocation(mapView: mapView)
            break
        default:
            break
        }
    }
} //: LocationManagerDelegate
