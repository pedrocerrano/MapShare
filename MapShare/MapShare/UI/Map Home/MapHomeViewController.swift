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
    @IBOutlet weak var clearRouteAnnotationsButton: UIButton!
    
    
    // MARK: - Properties
    var mapHomeViewModel: MapHomeViewModel!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        registerMapAnnotations()
        setupModalHomeSheetController()
        navigationItem.hidesBackButton = true
        mapHomeViewModel = MapHomeViewModel(delegate: self)
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
        locationManagerDidChangeAuthorization(mapHomeViewModel.locationManager)
        configureUI()
    }
    
    
    // MARK: - IB Actions
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
    }
    
    @IBAction func clearRouteAnnotationsButtonTapped(_ sender: Any) {
        guard let routeAnnotations = mapHomeViewModel.mapShareSession?.routeAnnotations else { return }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        mapHomeViewModel.deleteRouteFromFirestore()
        UIElements.hideRouteAnnotationButton(for: clearRouteAnnotationsButton)
    }
    
    
    //MARK: - UI and MODEL FUNCTIONS
    func configureUI() {
        UIElements.hideRouteAnnotationButton(for: clearRouteAnnotationsButton)
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
    }
    
    func delegateRemoveAnnotations() {
        sessionActivityIndicatorLabel.textColor = .systemGray
        mapView.removeAnnotations(mapView.annotations)
        mapHomeViewModel.memberAnnotations = []
    }
    
    func updateMemberCounts() {
        guard let members                = mapHomeViewModel.mapShareSession?.members else { return }
        let activeMembers                = members.filter { $0.isActive }.count
        let waitingRoomMembers           = members.filter { !$0.isActive }.count
        membersInActiveSessionLabel.text = "\(activeMembers)"
        membersInWaitingRoomLabel.text   = "\(waitingRoomMembers)"
    }
    
    
    //MARK: - MAPKIT FUNCTIONS
    func loadMemberAnnotations() {
        for memberAnnotation in mapHomeViewModel.memberAnnotations {
            mapView.addAnnotation(memberAnnotation)
        }
    }
    
    func removeMemberAnnotation(_ member: Member) {
        let memberAnnotations = mapHomeViewModel.memberAnnotations
        for memberAnnotation in memberAnnotations {
            if member.memberDeviceID == memberAnnotation.member.memberDeviceID {
                guard let index = mapHomeViewModel.memberAnnotations.firstIndex(of: memberAnnotation) else { return }
                mapHomeViewModel.memberAnnotations.remove(at: index)
            }
        }
        #warning("This doesn't do what I want")
    }
    
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.organizerDeviceID == Constants.Device.deviceID {
            let tappedLocation     = gestureRecognizer.location(in: mapView)
            let tappedCoordinate   = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            let newRouteAnnotation = RouteAnnotation(coordinate: tappedCoordinate, title: nil)
            UIElements.showRouteAnnotationButton(for: clearRouteAnnotationsButton)
            session.routeAnnotations.append(newRouteAnnotation)
            
            mapHomeViewModel.saveRouteToFirestore(newRouteAnnotation: newRouteAnnotation)
            
            if session.routeAnnotations.count > 1 {
                mapView.removeAnnotations(session.routeAnnotations)
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
    
    @objc func getDirections(annotation: MKAnnotation) {
        guard let members = mapHomeViewModel.mapShareSession?.members else { return }
        for member in members {
            let location   = CLLocationCoordinate2D(latitude: member.currentLocLatitude, longitude: member.currentLocLongitude)
            let request    = mapHomeViewModel.createDirectionsRequest(from: location, annotation: annotation)
            let directions = MKDirections(request: request)
            resetMapView(withNew: directions)
            directions.calculate { response, error in
                if let error = error {
                    print(error.localizedDescription) ; return
                }
                
                guard let response = response else { return }
                for route in response.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 70, bottom: 200, right: 70), animated: true)
                }
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
        let alert = UIAlertController(title: "Permission Has Been Denied Or Restricted", message: "In order to utilize this application, we need access to your location.", preferredStyle: .alert)
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
        mapHomeViewModel.memberAnnotation?.coordinate = userLocation.coordinate
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
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        if let members = mapHomeViewModel.mapShareSession?.members {
            for member in members {
                #warning("The title might be key to multiple colors")
                renderer.polyline.title = member.screenName
                let renderColor = String.convertToColorFromString(string: member.mapMarkerColor)
                renderer.strokeColor = renderColor
            }
        } else {
            renderer.strokeColor = UIElements.Color.mapSharePink
        }
        return renderer
    }
    
    func registerMapAnnotations() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Route")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Member")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let routeAnnotation = view.annotation, routeAnnotation.isKind(of: RouteAnnotation.self) {
            getDirections(annotation: routeAnnotation)
        }
    }
} //: MapViewDelegate


//MARK: - EXT: ViewModelDelegate
extension MapHomeViewController: MapHomeViewModelDelegate {
    func changesInSession() {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        if session.isActive == true {
            sessionActivityIndicatorLabel.textColor = UIElements.Color.mapShareGreen
        }
    }
    
    func changesInMembers() {
        mapHomeViewModel.createMemberAnnotations()
        updateMemberCounts()
        guard let session = mapHomeViewModel.mapShareSession else { return }
        for member in session.members {
            if Constants.Device.deviceID == member.memberDeviceID && member.isActive {
                loadMemberAnnotations()
            }
        }
        
        guard let waitingRoomMembers = mapHomeViewModel.mapShareSession?.members.filter({ !$0.isActive }) else { return }
        if waitingRoomMembers.count > 0 {
            waitingRoomStackView.backgroundColor = .yellow
        } else {
            waitingRoomStackView.backgroundColor = .clear
        }
    }
    
    func changesInRoute() {
        guard let routeAnnotations = mapHomeViewModel.mapShareSession?.routeAnnotations else { return }
        for routeAnnotation in routeAnnotations {
            mapView.removeAnnotations(routeAnnotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.addAnnotation(routeAnnotation)
        }
    }
    
    func noSessionActive() {
        sessionActivityIndicatorLabel.textColor = .systemGray
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        mapHomeViewModel.memberAnnotations = []
        mapView.showsUserLocation = true
        mapHomeViewModel.centerViewOnMember(mapView: mapView)
    }
} //: ViewModelDelegate
