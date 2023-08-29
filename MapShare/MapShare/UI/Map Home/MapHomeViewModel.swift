//
//  MapHomeViewModel.swift
//  MapShare
//
//  Created by Chase on 5/16/23.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

protocol MapHomeViewModelDelegate: AnyObject {
    func changesInSession()
    func changesInMembers()
    func changesInRoute()
    func noSessionActive()
}

class MapHomeViewModel {
    
    //MARK: - PROPERTIES
    var service: FirebaseService
    var sessionListener: ListenerRegistration?
    var memberListener: ListenerRegistration?
    var routesListener: ListenerRegistration?
    
    var mapShareSession: Session?
    private weak var delegate: MapHomeViewModelDelegate?
    
    var directionsArray: [MKDirections] = []
    let locationManager = CLLocationManager()
    var isDriving       = true
    var zoomsToFitAll   = true
    
    let routeDirectionsButton = UIButton(type: .detailDisclosure)
    
    init(service: FirebaseService = FirebaseService(), delegate: MapHomeViewModelDelegate) {
        self.service  = service
        self.delegate = delegate
    }
    
    
    //MARK: - FIREBASE LISTENERS
    func updateMapWithSessionChanges() {
        guard let mapShareSession else { return }
        sessionListener = service.firestoreListenToSession(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedSession):
                mapShareSession.isActive          = loadedSession.isActive
                mapShareSession.sessionCode       = loadedSession.sessionCode
                mapShareSession.sessionName       = loadedSession.sessionName
                mapShareSession.organizerDeviceID = loadedSession.organizerDeviceID
                self.delegate?.changesInSession()
            case .failure(let error):
                self.delegate?.noSessionActive()
                print(error.localizedDescription, "MapHomeViewModel: Session is nil")
            }
        }
    }
    
    func updateMapWithMemberChanges() {
        guard let mapShareSession else { return }
        memberListener = service.firestoreListenToMembers(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedMembers):
                mapShareSession.members = loadedMembers
                self.delegate?.changesInMembers()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: Members are nil")
            }
        }
    }
    
    func updateMapWithRouteChanges() {
        guard let mapShareSession else { return }
        routesListener = service.firestoreListenToRoutes(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedRouteAnnotations):
                mapShareSession.routeAnnotations = loadedRouteAnnotations
                self.delegate?.changesInRoute()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: RouteAnnotations are nil")
            }
        }
    }
    
    
    //MARK: - FIREBASE ROUTE CRUD FUNCTIONS
    func saveRouteToFirestore(newRouteAnnotation: RouteAnnotation) {
        guard let mapShareSession else { return }
        service.firestoreSaveNewRoute(forSession: mapShareSession, routeAnnotation: newRouteAnnotation)
    }
    
    func deleteRouteFromFirestore() {
        guard let mapShareSession else { return }
        service.firestoreDeleteRoute(fromSession: mapShareSession)
    }
    
    func updateMemberTravelTime(withMemberID deviceID: String, withTravelTime travelTime: Double) {
        guard let mapShareSession else { return }
        service.firestoreUpdateTravelTime(forSession: mapShareSession, withMemberID: deviceID, withTime: travelTime)
    }
    
    func updateMemberLocation(forMember member: Member, withLatitude: Double, withLongitude: Double) {
        guard let mapShareSession else { return }
        // This is the function to update Real-Time Location update with Ably
    }
    
    func updateToDriving() {
        guard let mapShareSession,
              let routeAnnotation = mapShareSession.routeAnnotations.first else { return }
        service.firestoreUpdateTransportTypeToDriving(forSession: mapShareSession, forRoute: routeAnnotation)
    }
    
    func updateToWalking() {
        guard let mapShareSession,
              let routeAnnotation = mapShareSession.routeAnnotations.first else { return }
        service.firestoreUpdateTransportTypeToWalking(forSession: mapShareSession, forRoute: routeAnnotation)
    }
    
    
    //MARK: - MAPKIT FUNCTIONS
    func shareDirections() {
        routeDirectionsButton.addTarget(self, action: #selector(routeButtonPressed), for: .touchUpInside)
    }
    
    @objc func routeButtonPressed() {
        guard let mapShareSession else { return }
        service.firestoreShareDirections(forSession: mapShareSession, using: mapShareSession.routeAnnotations[0])
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, annotation: MKAnnotation, withTravelType travelType: MKDirectionsTransportType) -> MKDirections.Request {
        let routeCoordinate   = annotation.coordinate
        let startingLocation  = MKPlacemark(coordinate: coordinate)
        let destination       = MKPlacemark(coordinate: routeCoordinate)
        
        let request           = MKDirections.Request()
        request.source        = MKMapItem(placemark: startingLocation)
        request.destination   = MKMapItem(placemark: destination)
        request.transportType = travelType
      
        return request
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude  = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func setupMemberAnnotations(for member: Member, on mapView: MKMapView) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Member", for: member)
        guard let markerColor = String.convertToColorFromString(string: member.color) else { return nil }
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout    = false
            markerAnnotationView.markerTintColor   = markerColor
        }
        return view
    }
    
    func setupRouteAnnotations(for routeAnnotation: RouteAnnotation, on mapView: MKMapView) -> MKAnnotationView? {
        routeAnnotation.title = "Route"
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Route", for: routeAnnotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.titleVisibility   = .hidden
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.glyphImage        = UIImage(systemName: "flag.checkered.2.crossed")
            markerAnnotationView.markerTintColor   = UIElements.Color.dodgerBlue
            markerAnnotationView.canShowCallout    = true
            routeDirectionsButton.setImage(UIImage(systemName: "arrowshape.turn.up.right.circle.fill"), for: .normal)
            markerAnnotationView.rightCalloutAccessoryView = routeDirectionsButton
        }
        return view
    }
    
    func startTrackingLocation(mapView: MKMapView) {
        mapView.showsUserLocation = true
        centerViewOnMember(mapView: mapView)
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    func centerViewOnMember(mapView: MKMapView) {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        mapView.setRegion(region, animated: true)
    }
}
