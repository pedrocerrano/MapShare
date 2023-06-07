//
//  MapHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/25/23.
//

import UIKit
import MapKit
import CoreLocation
import CoreLocationUI

class MapHomeViewController: UIViewController {
    
    //MARK: - OUTLETS
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
    @IBOutlet weak var refreshingLocationButton: UIButton!
    
    
    // MARK: - Properties
    var mapHomeViewModel: MapHomeViewModel!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        mapHomeViewModel = MapHomeViewModel(delegate: self)
        mapHomeViewModel.locationManager.delegate = self
        setupNewSessionSheetController()
        registerMapAnnotations()
        addGesture()
        configureUI()
    }
    
    
    // MARK: - IB Actions
    @IBAction func travelMethodButtonTapped(_ sender: Any) {
        guard let session = mapHomeViewModel.mapShareSession,
              let drivingImage = UIImage(systemName: "car.circle.fill"),
              let walkingImage = UIImage(systemName: "figure.walk") else { return }
        
        switch travelMethodButton.currentImage {
        case walkingImage:
            travelMethodButton.setImage(drivingImage, for: .normal)
            displayDirectionsForActiveMembers(forSession: session)
        case drivingImage:
            travelMethodButton.setImage(walkingImage, for: .normal)
            displayDirectionsForActiveMembers(forSession: session)
        default:
            travelMethodButton.setImage(drivingImage, for: .normal)
        }
    }
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
    }
    
    @IBAction func centerRouteButtonTapped(_ sender: Any) {
        resetZoomForPolylineRoutes()
    }
    
    @IBAction func clearRouteAnnotationsButtonTapped(_ sender: Any) {
        let routeAnnotations = mapView.annotations.filter { !($0 is MemberAnnotation) }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        mapHomeViewModel.deleteRouteFromFirestore()
        centerRouteButton.isHidden           = true
        clearRouteAnnotationsButton.isHidden = true
        guard let activeMembers = mapHomeViewModel.mapShareSession?.members else { return }
        if activeMembers.count == 1 {
            mapHomeViewModel.centerViewOnMember(mapView: mapView)
        } else {
            let memberAnnotations = mapView.annotations.filter { ($0 is MemberAnnotation) }
            mapView.showAnnotations(memberAnnotations, animated: true)
        }
        for member in activeMembers {
            mapHomeViewModel.updateMemberTravelTime(withMemberID: member.memberDeviceID, withTravelTime: -1)
        }
    }
    
    @IBAction func refreshLocationButtonTapped(_ sender: Any) {
        guard let coordinates       = mapHomeViewModel.locationManager.location?.coordinate,
              let memberAnnotations = mapHomeViewModel.mapShareSession?.memberAnnotations,
              let currentMember     = memberAnnotations.first(where: { Constants.Device.deviceID == $0.deviceID }) else { return }
        
        mapHomeViewModel.updateMemberAnnotationLocation(forMemberAnnotation: currentMember, withLatitude: coordinates.latitude, withLongitude: coordinates.longitude)
    }
    
    
    //MARK: - UI and MODEL FUNCTIONS
    private func configureUI() {
        UIElements.configureLabelUI(for: sessionActivityIndicatorLabel)
        activeMembersStackView.isHidden      = true
        waitingRoomStackView.isHidden        = true
        navigationItem.hidesBackButton       = true
        travelMethodButton.isHidden          = true
        centerRouteButton.isHidden           = true
        clearRouteAnnotationsButton.isHidden = true
        refreshingLocationButton.isHidden    = true
        UIElements.configureFilledStyleButtonAttributes(for: travelMethodButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureFilledStyleButtonAttributes(for: centerLocationButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureFilledStyleButtonAttributes(for: centerRouteButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureFilledStyleButtonAttributes(for: clearRouteAnnotationsButton, withColor: .systemGray3)
        clearRouteAnnotationsButton.configuration?.baseForegroundColor = .label
        UIElements.configureFilledStyleButtonAttributes(for: refreshingLocationButton, withColor: UIElements.Color.mapShareGreen)
    }
    
    private func setupNewSessionSheetController() {
        let storyboard = UIStoryboard(name: "NewSession", bundle: nil)
        guard let sheetController = storyboard.instantiateViewController(withIdentifier: "NewSessionVC") as? NewSessionViewController else { return }
        sheetController.isModalInPresentation = true
        sheetController.newSessionViewModel = NewSessionViewModel(mapHomeDelegate: self)
        self.parent?.present(sheetController, animated: true, completion: nil)
    }
    
    func delegateUpdateWithSession(session: Session) {
        mapHomeViewModel.mapShareSession = session
        mapHomeViewModel.updateMapWithSessionChanges()
        mapHomeViewModel.updateMapWithMemberChanges()
        mapHomeViewModel.updateMapWithRouteChanges()
        mapHomeViewModel.updateMapWithMemberAnnotations()
        mapHomeViewModel.shareDirections()
    }
    
    private func updateMemberCounts() {
        guard let members                = mapHomeViewModel.mapShareSession?.members else { return }
        let activeMembers                = members.filter { $0.isActive }.count
        let waitingRoomMembers           = members.filter { !$0.isActive }.count
        membersInActiveSessionLabel.text = "\(activeMembers)"
        membersInWaitingRoomLabel.text   = "\(waitingRoomMembers)"
    }
    
    
    //MARK: - MAPKIT FUNCTIONS
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.organizerDeviceID == Constants.Device.deviceID && session.isActive && session.routeAnnotations.isEmpty {
            let tappedLocation     = gestureRecognizer.location(in: mapView)
            let tappedCoordinate   = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            let newRouteAnnotation = RouteAnnotation(coordinate: tappedCoordinate, title: nil, isShowingDirections: false)
            mapHomeViewModel.saveRouteToFirestore(newRouteAnnotation: newRouteAnnotation)
            clearRouteAnnotationsButton.isHidden = false
            travelMethodButton.isHidden          = false
        } else {
            return
        }
    }
    
    private func getDirections(routeAnnotation: MKAnnotation) {
        guard let memberAnnotationsShowing = mapHomeViewModel.mapShareSession?.memberAnnotations.filter ({ $0.isShowing }) else { return }
        for memberAnnotation in memberAnnotationsShowing {
            let location   = CLLocationCoordinate2D(latitude: memberAnnotation.coordinate.latitude, longitude: memberAnnotation.coordinate.longitude)
            let request    = mapHomeViewModel.createDirectionsRequest(from: location, annotation: routeAnnotation, withButton: travelMethodButton)
            let directions = MKDirections(request: request)
            resetMapView(withNew: directions)
            directions.calculate { response, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let response = response else { return }
                for route in response.routes {
                    self.mapHomeViewModel.updateMemberTravelTime(withMemberID: memberAnnotation.deviceID, withTravelTime: route.expectedTravelTime)
                    route.polyline.title = memberAnnotation.title
                    self.mapView.addOverlay(route.polyline)
                    self.resetZoomForPolylineRoutes()
                }
            }
        }
    }
    
    private func displayDirectionsForActiveMembers(forSession session: Session) {
        for newRouteAnnotation in session.routeAnnotations {
            mapView.addAnnotation(newRouteAnnotation)
            
            if newRouteAnnotation.isShowingDirections {
                getDirections(routeAnnotation: newRouteAnnotation)
            }
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        mapHomeViewModel.directionsArray.append(directions)
        let _ = mapHomeViewModel.directionsArray.map { $0.cancel() }
    }
    
    private func resetZoomForPolylineRoutes() {
        guard let polylineOverlay = self.mapView.overlays.first else { return }
        let newMapRect = self.mapView.overlays.reduce(polylineOverlay.boundingMapRect, { $0.union($1.boundingMapRect)} )
        mapView.setVisibleMapRect(newMapRect, edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 200, right: 80), animated: true)
    }
} //: CLASS


//MARK: - EXT: LocationManagerDelegate
extension MapHomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch mapHomeViewModel.locationManager.authorizationStatus {
        case .notDetermined:
            mapHomeViewModel.locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            NotificationCenter.default.post(name: Constants.Notifications.locationAccessNeeded, object: nil)
            break
        case .authorizedWhenInUse:
            mapHomeViewModel.startTrackingLocation(mapView: mapView)
            break
        default:
            break
        }
    }
} //: LocationManagerDelegate


//MARK: - EXT: MapViewDelegate
extension MapHomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        if let routeAnnotation = annotation as? RouteAnnotation {
            annotationView = mapHomeViewModel.setupRouteAnnotations(for: routeAnnotation, on: mapView)
            return annotationView
        } else if let memberAnnotation = annotation as? MemberAnnotation {
            annotationView = mapHomeViewModel.setupMemberAnnotations(for: memberAnnotation, on: mapView)
            mapView.showsUserLocation = false
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay   = overlay as? MKPolyline,
              let activeMembers  = mapHomeViewModel.mapShareSession?.members.filter ({ $0.isActive }),
              let routeTitle     = routeOverlay.title,
              let mapMarkerColor = activeMembers.first(where: { $0.screenName == routeTitle })?.mapMarkerColor else { return MKOverlayRenderer() }
        let strokeColor      = String.convertToColorFromString(string: mapMarkerColor)
        let renderer         = MKPolylineRenderer(overlay: routeOverlay)
        renderer.strokeColor = strokeColor
        return renderer
    }
    
    private func registerMapAnnotations() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Route")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Member")
    }
} //: MapViewDelegate


//MARK: - EXT: ViewModelDelegate
extension MapHomeViewController: MapHomeViewModelDelegate {
    func changesInSession() {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.isActive {
            sessionActivityIndicatorLabel.textColor = UIElements.Color.mapShareGreen
        }
    }
    
    func changesInMembers() {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.members.first(where: { Constants.Device.deviceID == $0.memberDeviceID && $0.isActive }) != nil {
            activeMembersStackView.isHidden   = false
            waitingRoomStackView.isHidden     = false
            refreshingLocationButton.isHidden = false
            updateMemberCounts()
            
            let waitingRoomMembers = session.members.filter { !$0.isActive }
            if waitingRoomMembers.count > 0 {
                waitingRoomStackView.backgroundColor = .yellow
            } else {
                waitingRoomStackView.backgroundColor = .clear
            }
        }
    }
    
    func changesInRoute() {
        let routeAnnotations = mapView.annotations.filter { !($0 is MemberAnnotation) }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.members.first(where: { Constants.Device.deviceID == $0.memberDeviceID && $0.isActive }) != nil {
            displayDirectionsForActiveMembers(forSession: session)
            
            if !session.routeAnnotations.isEmpty && session.routeAnnotations.first(where: { $0.isShowingDirections }) != nil {
                centerRouteButton.isHidden = false
            } else {
                centerRouteButton.isHidden = true
            }
        }
    }
    
    func changesInMemberAnnotations() {
        #warning("This clears ALL memberAnnotations. It will not work for real-time updates")
        let existingMemberAnnotations = mapView.annotations.filter { ($0 is MemberAnnotation) }
        mapView.removeAnnotations(existingMemberAnnotations)
        
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.members.first(where: { Constants.Device.deviceID == $0.memberDeviceID && $0.isActive }) != nil {
            let memberAnnotationsShowing = session.memberAnnotations.filter { $0.isShowing }
            mapView.addAnnotations(memberAnnotationsShowing)
            if memberAnnotationsShowing.count > 1 {
                mapView.showAnnotations(memberAnnotationsShowing, animated: true)
            }
        }
    }
    
    func noSessionActive() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        activeMembersStackView.isHidden                     = true
        waitingRoomStackView.isHidden                       = true
        travelMethodButton.isHidden                         = true
        mapHomeViewModel.mapShareSession?.isActive          = false
        mapHomeViewModel.mapShareSession?.memberAnnotations = []
        mapHomeViewModel.mapShareSession?.members           = []
        updateMemberCounts()
        mapHomeViewModel.mapShareSession                    = nil
        mapView.showsUserLocation                           = true
        sessionActivityIndicatorLabel.textColor             = .systemGray
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
        mapHomeViewModel.sessionListener?.remove()
        mapHomeViewModel.memberListener?.remove()
        mapHomeViewModel.routesListener?.remove()
        mapHomeViewModel.memberAnnotationsListener?.remove()
    }
} //: ViewModelDelegate
