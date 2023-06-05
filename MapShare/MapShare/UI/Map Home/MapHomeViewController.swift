//
//  MapHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/25/23.
//

import Foundation
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
    var timer: Timer?
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        mapHomeViewModel = MapHomeViewModel(delegate: self)
        mapHomeViewModel.locationManager.delegate = self
        setupNewSessionSheetController()
        registerMapAnnotations()
        addGesture()
        configureUI()
        startTimer()
    }
    
    
    // MARK: - IB Actions
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
    }
    
    @IBAction func clearRouteAnnotationsButtonTapped(_ sender: Any) {
        let routeAnnotations = mapView.annotations.filter { !($0 is MemberAnnotation) }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        mapHomeViewModel.deleteRouteFromFirestore()
        UIElements.hideRouteAnnotationButton(for: clearRouteAnnotationsButton)
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

    }
    
    
    //MARK: - UI and MODEL FUNCTIONS
    private func configureUI() {
        UIElements.configureLabelUI(for: sessionActivityIndicatorLabel)
        activeMembersStackView.isHidden = true
        waitingRoomStackView.isHidden   = true
        navigationItem.hidesBackButton  = true
        UIElements.configureFilledStyleButtonAttributes(for: centerLocationButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureFilledStyleButtonAttributes(for: refreshingLocationButton, withColor: UIElements.Color.mapShareGreen)
        UIElements.hideRouteAnnotationButton(for: clearRouteAnnotationsButton)
        UIElements.hideLocationRefreshButton(for: refreshingLocationButton)
        navigationItem.hidesBackButton = true
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
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired() {
        guard let coordinates       = mapHomeViewModel.locationManager.location?.coordinate,
              let memberAnnotations = mapHomeViewModel.mapShareSession?.memberAnnotations,
              let currentMember     = memberAnnotations.first(where: { Constants.Device.deviceID == $0.deviceID }) else { return }
        
        let memberLatitude  = coordinates.latitude
        let memberLongitude = coordinates.longitude
        
        mapHomeViewModel.updateMemberAnnotationLocation(forMemberAnnotation: currentMember, withLatitude: memberLatitude, withLongitude: memberLongitude)
        
        print("Location Updated")
    }
    
    private func addGesture() {
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.organizerDeviceID == Constants.Device.deviceID && session.isActive == true {
            let tappedLocation     = gestureRecognizer.location(in: mapView)
            let tappedCoordinate   = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            let newRouteAnnotation = RouteAnnotation(coordinate: tappedCoordinate, title: nil, isShowingDirections: false)
            mapHomeViewModel.saveRouteToFirestore(newRouteAnnotation: newRouteAnnotation)
            UIElements.showRouteAnnotationButton(for: clearRouteAnnotationsButton)
        } else {
            return
        }
    }
    
    private func getDirections(routeAnnotation: MKAnnotation) {
        guard let memberAnnotationsShowing = mapHomeViewModel.mapShareSession?.memberAnnotations.filter ({ $0.isShowing }) else { return }
        for memberAnnotation in memberAnnotationsShowing {
            let location   = CLLocationCoordinate2D(latitude: memberAnnotation.coordinate.latitude, longitude: memberAnnotation.coordinate.longitude)
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
                    self.mapHomeViewModel.updateMemberTravelTime(withMemberID: memberAnnotation.deviceID, withTravelTime: route.expectedTravelTime)
                    route.polyline.title = memberAnnotation.title
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 70, bottom: 200, right: 70), animated: true)
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
            UIElements.showLocationRefreshButton(for: refreshingLocationButton)
            
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
//            updateAnnotations()
            mapView.addAnnotations(memberAnnotationsShowing)
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
