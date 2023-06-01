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
    @IBOutlet weak var waitingRoomStackView: UIStackView!
    @IBOutlet weak var centerLocationButton: UIButton!
    @IBOutlet weak var clearRouteAnnotationsButton: UIButton!
    @IBOutlet weak var refreshingLocationButton: UIButton!
    
    
    // MARK: - Properties
    var mapHomeViewModel: MapHomeViewModel!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        configureUI()
        registerMapAnnotations()
        setupModalHomeSheetController()
        navigationItem.hidesBackButton = true
        mapHomeViewModel = MapHomeViewModel(delegate: self)
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
        locationManagerDidChangeAuthorization(mapHomeViewModel.locationManager)
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
    }
    
    @IBAction func refreshLocationButtonTapped(_ sender: Any) {
        let manager = mapHomeViewModel.locationManager
        guard let currentMember = mapHomeViewModel.mapShareSession?.members.filter( { $0.memberDeviceID == Constants.Device.deviceID }).first else { return }
        mapHomeViewModel.updateMemberLocation(forMember: currentMember, withLatitude: manager.location?.coordinate.latitude ?? 0, withLongitude: manager.location?.coordinate.longitude ?? 0)
    }
    
    
    
    //MARK: - UI and MODEL FUNCTIONS
    func configureUI() {
        UIElements.configureFilledStyleButtonAttributes(for: centerLocationButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureFilledStyleButtonAttributes(for: refreshingLocationButton, withColor: UIElements.Color.mapShareGreen)
        UIElements.hideRouteAnnotationButton(for: clearRouteAnnotationsButton)
        UIElements.hideLocationRefreshButton(for: refreshingLocationButton)
    }
    
    func setupModalHomeSheetController() {
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
    
    func updateMemberCounts() {
        guard let members                = mapHomeViewModel.mapShareSession?.members else { return }
        let activeMembers                = members.filter { $0.isActive }.count
        let waitingRoomMembers           = members.filter { !$0.isActive }.count
        membersInActiveSessionLabel.text = "\(activeMembers)"
        membersInWaitingRoomLabel.text   = "\(waitingRoomMembers)"
    }
    
    
    //MARK: - MAPKIT FUNCTIONS
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.organizerDeviceID == Constants.Device.deviceID && session.isActive == true {
            let tappedLocation     = gestureRecognizer.location(in: mapView)
            let tappedCoordinate   = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            let newRouteAnnotation = RouteAnnotation(coordinate: tappedCoordinate, title: nil, isShowingDirections: false)
            session.routeAnnotations.append(newRouteAnnotation)
            mapHomeViewModel.saveRouteToFirestore(newRouteAnnotation: newRouteAnnotation)
            UIElements.showRouteAnnotationButton(for: clearRouteAnnotationsButton)
            
            let routeAnnotations = mapView.annotations.filter { !($0 is MemberAnnotation) }
            if routeAnnotations.count > 1 {
                mapView.removeAnnotations(routeAnnotations)
                mapView.removeOverlays(mapView.overlays)
                mapView.addAnnotation(newRouteAnnotation)
            } else {
                mapView.addAnnotation(newRouteAnnotation)
            }
        } else {
            return
        }
    }
    
    func checkLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.mapHomeViewModel.locationManager.delegate = self
                self.mapHomeViewModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.mapHomeViewModel.locationManager.startUpdatingLocation()
            } else {
                self.alertLocationAccessNeeded()
            }
        }
    }
    
    func getDirections(routeAnnotation: MKAnnotation) {
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
                    member.expectedTravelTime = route.expectedTravelTime
                    self.mapHomeViewModel.updateMemberTravelTime(forMember: member, withTravelTime: route.expectedTravelTime)
                    route.polyline.title = member.screenName
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 70, bottom: 200, right: 70), animated: true)
                }
            }
        }
    }
    
    func displayDirectionsForActiveMembers(forSession session: Session) {
        for newRouteAnnotation in session.routeAnnotations {
            mapView.addAnnotation(newRouteAnnotation)
            
            if newRouteAnnotation.isShowingDirections {
                getDirections(routeAnnotation: newRouteAnnotation)
            }
        }
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        mapHomeViewModel.directionsArray.append(directions)
        let _ = mapHomeViewModel.directionsArray.map { $0.cancel() }
    }
    
    func alertLocationAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        let alert = UIAlertController(title: "Permission Has Been Denied Or Restricted", message: "In order to utilize MapShare, we need access to your location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Go To Settings", style: .default, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL)
        }))
        present(alert, animated: true, completion: nil)
    }
} //: CLASS


//MARK: - EXT: LocationManagerDelegate
extension MapHomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationServices()
        switch mapHomeViewModel.locationManager.authorizationStatus {
        case .notDetermined:
            mapHomeViewModel.locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            alertLocationAccessNeeded()
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
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }
    
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
        guard let activeMembers = mapHomeViewModel.mapShareSession?.members.filter ({ $0.isActive }),
              let routeOverlay = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(overlay: routeOverlay)

        for member in activeMembers {
            if member.screenName == routeOverlay.title  {
                renderer.strokeColor = String.convertToColorFromString(string: member.mapMarkerColor)
                return renderer
            } else {
                renderer.strokeColor = .black
                return renderer
            }
        }

        return MKOverlayRenderer()
    }
    
    func registerMapAnnotations() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Route")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Member")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let routeAnnotation = view.annotation, routeAnnotation.isKind(of: RouteAnnotation.self) {
            getDirections(routeAnnotation: routeAnnotation)
        }
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
        
        let activeMembers = session.members.filter { $0.isActive }
        for _ in activeMembers {
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
        for member in session.members {
            if Constants.Device.deviceID == member.memberDeviceID && member.isActive {
                displayDirectionsForActiveMembers(forSession: session)
            }
        }
    }
    
    func changesInMemberAnnotations() {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        let activeMembers = session.members.filter { $0.isActive }
        for _ in activeMembers {
            let memberAnnotationsShowing = session.memberAnnotations.filter { $0.isShowing }
            mapView.addAnnotations(memberAnnotationsShowing)
        }
    }
    
    func noSessionActive() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
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
