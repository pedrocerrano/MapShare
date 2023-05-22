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
        mapHomeViewModel.centerViewOnUser(mapView: mapView)
        locationManagerDidChangeAuthorization(mapHomeViewModel.locationManager)
    }
    
    
    // MARK: - IB Actions
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        mapHomeViewModel.centerViewOnUser(mapView: mapView)
    }
    
    @IBAction func clearRouteAnnotationsButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK: - FUNCTIONS
    func loadAnnotations() {
        for annotation in mapHomeViewModel.memberAnnotations {
            mapView.addAnnotation(annotation)
        }
    }
    
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = CustomAnnotation(coordinate: coordinate, title: nil)
        annotation.coordinate = coordinate
        mapHomeViewModel.customAnnotations.append(annotation)
        
        if mapHomeViewModel.customAnnotations.count > 1 {
            mapView.removeAnnotations(mapHomeViewModel.customAnnotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.addAnnotation(annotation)
        } else {
            mapView.addAnnotation(annotation)
        }
    }
    
    func setupModalHomeSheetController() {
        let storyboard = UIStoryboard(name: "NewSession", bundle: nil)
        guard let sheetController = storyboard.instantiateViewController(withIdentifier: "NewSessionVC") as? NewSessionViewController else { return }
        sheetController.isModalInPresentation = true
        sheetController.newSessionViewModel = NewSessionViewModel(mapHomeDelegate: self)
        self.parent?.present(sheetController, animated: true, completion: nil)
    }
    
    func delegateUpdateWithSession(session: Session) {
        mapHomeViewModel.session = session
        mapHomeViewModel.listenForSessionChanges()
        mapHomeViewModel.listenForMemberChanges()
    }
    
    func delegateRemoveAnnotations() {
        sessionActivityIndicatorLabel.textColor = .systemGray
        mapView.removeAnnotations(mapView.annotations)
        mapHomeViewModel.customAnnotations = []
    }
    
    func updateMemberCounts() {
        guard let members                = mapHomeViewModel.session?.members else { return }
        let activeMembers                = members.filter { $0.isActive == true }.count
        let waitingRoomMembers           = members.filter { $0.isActive == false }.count
        membersInActiveSessionLabel.text = "\(activeMembers)"
        membersInWaitingRoomLabel.text   = "\(waitingRoomMembers)"
        #warning("Troubleshoot why this doesn't change")
    }
    
    func checkLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.mapHomeViewModel.locationManager.delegate = self
                self.mapHomeViewModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            } else {
                self.alertLocationAccessNeeded()
            }
        }
    }
    
    @objc func getDirections(annotation: MKAnnotation) {
        guard let location = mapHomeViewModel.locationManager.location?.coordinate else {
            alertLocationAccessNeeded()
            return
        }
        
        let request = mapHomeViewModel.createDirectionsRequest(from: location, annotation: annotation)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        directions.calculate { response, error in
            if let error = error {
                print(error.localizedDescription) ; return
            }
            
            guard let response = response else { return }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
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

extension MapHomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        if let annotation = annotation as? CustomAnnotation {
            annotationView = mapHomeViewModel.setupCustomAnnotations(for: annotation, on: mapView)
            return annotationView
        } else if let annotation = annotation as? MemberAnnotation {
            annotationView = mapHomeViewModel.setupMemberAnnotations(for: annotation, on: mapView)
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        guard let members = mapHomeViewModel.session?.members else { return MKOverlayRenderer(overlay: renderer as! MKOverlay)}
        for member in members {
            let renderColor = String.convertToColorFromString(string: member.mapMarkerColor)
            renderer.strokeColor = renderColor
        }
        return renderer
    }
    
    func registerMapAnnotations() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Route")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Member")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let customAnnotation = view.annotation, customAnnotation.isKind(of: CustomAnnotation.self) {
            getDirections(annotation: customAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if annotation.isKind(of: CustomAnnotation.self) {
            mapHomeViewModel.annotation = (annotation as! CustomAnnotation)
        }
    }
} //: MapViewDelegate

extension MapHomeViewController: MapHomeViewModelDelegate {
    func changesInSession() {
        guard let session = mapHomeViewModel.session else { return }
        if session.isActive == true {
            sessionActivityIndicatorLabel.textColor = UIElements.Color.mapShareGreen
        }
    }
    
    func changesInMembers() {
        loadAnnotations()
        updateMemberCounts()
        mapView.reloadInputViews()
    }
    
    func noSessionActive() {
        sessionActivityIndicatorLabel.textColor = .systemGray
        mapView.removeAnnotations(mapView.annotations)
        mapHomeViewModel.customAnnotations = []
    }
} //: ViewModelDelegate
