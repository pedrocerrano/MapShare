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
    @IBOutlet weak var centerLocationButton: UIButton!
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
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
//        mapHomeViewModel.centerViewOnMember(mapView: mapView)
        
    }
    
    @IBAction func clearRouteAnnotationsButtonTapped(_ sender: Any) {
        let routeAnnotations = mapView.annotations.filter { !($0 is MemberAnnotation) }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        mapHomeViewModel.deleteRouteFromFirestore()
        clearRouteAnnotationsButton.isHidden = true
        guard let activeMembers = mapHomeViewModel.mapShareSession?.members else { return }
        if activeMembers.count == 1 {
            mapHomeViewModel.centerViewOnMember(mapView: mapView)
        } else {
            let memberAnnotations = mapView.annotations.filter { ($0 is MemberAnnotation) }
            mapView.showAnnotations(memberAnnotations, animated: true)
        }
        for member in activeMembers {
            mapHomeViewModel.updateMemberTravelTime(forMember: member, withTravelTime: -1)
        }
    }
    
    @IBAction func refreshLocationButtonTapped(_ sender: Any) {
        let manager = mapHomeViewModel.locationManager
        guard let currentMember = mapHomeViewModel.mapShareSession?.members.filter( { $0.memberDeviceID == Constants.Device.deviceID }).first else { return }
        mapHomeViewModel.updateMemberLocation(forMember: currentMember, withLatitude: manager.location?.coordinate.latitude ?? 0, withLongitude: manager.location?.coordinate.longitude ?? 0)
    }
    
    
    
    //MARK: - UI and MODEL FUNCTIONS
    private func configureUI() {
        UIElements.configureLabelUI(for: sessionActivityIndicatorLabel)
        activeMembersStackView.isHidden      = true
        waitingRoomStackView.isHidden        = true
        navigationItem.hidesBackButton       = true
        clearRouteAnnotationsButton.isHidden = true
        refreshingLocationButton.isHidden    = true
        UIElements.configureFilledStyleButtonAttributes(for: centerLocationButton, withColor: UIElements.Color.dodgerBlue)
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
        if session.organizerDeviceID == Constants.Device.deviceID && session.isActive == true {
            let tappedLocation     = gestureRecognizer.location(in: mapView)
            let tappedCoordinate   = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            let newRouteAnnotation = RouteAnnotation(coordinate: tappedCoordinate, title: nil, isShowingDirections: false)
            mapHomeViewModel.saveRouteToFirestore(newRouteAnnotation: newRouteAnnotation)
            clearRouteAnnotationsButton.isHidden = false
        } else {
            return
        }
    }
    
    private func getDirections(routeAnnotation: MKAnnotation) {
        guard let activeMembers = mapHomeViewModel.mapShareSession?.members.filter ({ $0.isActive }) else { return }
        for member in activeMembers {
            let location   = CLLocationCoordinate2D(latitude: member.currentLocLatitude, longitude: member.currentLocLongitude)
            let request    = mapHomeViewModel.createDirectionsRequest(from: location, annotation: routeAnnotation)
            let directions = MKDirections(request: request)
            resetMapView(withNew: directions)
            directions.calculate { response, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let response = response else { return }
                for route in response.routes {
                    self.mapHomeViewModel.updateMemberTravelTime(forMember: member, withTravelTime: route.expectedTravelTime)
                    route.polyline.title = member.screenName
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
        mapView.setVisibleMapRect(newMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 200, right: 50), animated: true)
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
            activeMembersStackView.isHidden = false
            waitingRoomStackView.isHidden   = false
            updateMemberCounts()
            refreshingLocationButton.isHidden = false
            
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
        }
    }
    
    func changesInMemberAnnotations() {
        let existinMemberAnnotations = mapView.annotations.filter { ($0 is MemberAnnotation) }
        mapView.removeAnnotations(existinMemberAnnotations)
        
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
        mapHomeViewModel.mapShareSession?.isActive          = false
        mapHomeViewModel.mapShareSession?.memberAnnotations = []
        mapHomeViewModel.mapShareSession?.members           = []
        updateMemberCounts()
        mapHomeViewModel.mapShareSession                    = nil
        mapView.showsUserLocation                           = true
        sessionActivityIndicatorLabel.textColor             = .systemGray
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
        UIElements.hideRouteAnnotationButton(for: clearRouteAnnotationsButton)
        UIElements.hideLocationRefreshButton(for: refreshingLocationButton)
    }
} //: ViewModelDelegate
