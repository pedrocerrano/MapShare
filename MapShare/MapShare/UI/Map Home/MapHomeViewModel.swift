//
//  MapHomeViewModel.swift
//  MapShare
//
//  Created by Chase on 5/16/23.
//

import UIKit
import MapKit
import CoreLocation

protocol MapHomeViewModelDelegate: AnyObject {
    func changesInSession()
    func changesInMembers()
    func changesInRoute()
    func changesInMemberAnnotations()
    func noSessionActive()
}

class MapHomeViewModel {
    
    //MARK: - PROPERTIES
    var service: FirebaseService
    var mapShareSession: Session?
    private weak var delegate: MapHomeViewModelDelegate?
    
    var directionsArray: [MKDirections] = []
    let locationManager = CLLocationManager()
    
    let routeDirectionsButton = UIButton(type: .detailDisclosure)
    
    init(service: FirebaseService = FirebaseService(), delegate: MapHomeViewModelDelegate) {
        self.service           = service
        self.delegate          = delegate
    }
    
    //MARK: - FIREBASE LISTENER FUNCTIONS
    func updateMapWithSessionChanges() {
        guard let mapShareSession else { return }
        service.listenForChangesToSession(forSession: mapShareSession) { result in
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
        service.listenForChangesToMembers(forSession: mapShareSession) { result in
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
        service.listenToChangesForRoutes(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedRouteAnnotations):
                mapShareSession.routeAnnotations = loadedRouteAnnotations
                self.delegate?.changesInRoute()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: RouteAnnotations are nil")
            }
        }
    }
    
    func updateMapWithMemberAnnotations() {
        guard let mapShareSession else { return }
        service.listenToChangesToMemberAnnotations(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedMemberAnnotations):
                mapShareSession.memberAnnotations = loadedMemberAnnotations
                self.delegate?.changesInMemberAnnotations()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: MemberAnnotations are nil")
            }
        }
    }
    
    
    //MARK: - FIREBASE ROUTE CRUD FUNCTIONS
    func saveRouteToFirestore(newRouteAnnotation: RouteAnnotation) {
        guard let mapShareSession else { return }
        service.saveNewRouteToFirestore(forSession: mapShareSession, routeAnnotation: newRouteAnnotation)
    }
    
    func deleteRouteFromFirestore() {
        guard let mapShareSession else { return }
        service.deleteRouteOnFirestore(fromSession: mapShareSession)
    }
    
    func updateMemberTravelTime(forMember member: Member, withTravelTime travelTime: Double) {
        guard let mapShareSession else { return }
        service.updateExpectedTravelTime(forSession: mapShareSession, forMember: member, withTime: travelTime)
    }
    
    func updateMemberLocation(forMember member: Member, withLatitude: Double, withLongitude: Double) {
        guard let mapShareSession else { return }
        service.updateLocationOfMemberToFirestore(forSession: mapShareSession, forMember: member, withLatitude: withLatitude, withLongitude: withLongitude)
    }
    
    
    //MARK: - MAPKIT FUNCTIONS
    func shareDirections() {
        routeDirectionsButton.addTarget(self, action: #selector(routeButtonPressed), for: .touchUpInside)
    }
    
    @objc func routeButtonPressed() {
        guard let mapShareSession else { return }
        service.showDirectionsToMembers(forSession: mapShareSession, using: mapShareSession.routeAnnotations[0])
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, annotation: MKAnnotation) -> MKDirections.Request {
        let routeCoordinate   = annotation.coordinate
        let startingLocation  = MKPlacemark(coordinate: coordinate)
        let destination       = MKPlacemark(coordinate: routeCoordinate)
        
        let request           = MKDirections.Request()
        request.source        = MKMapItem(placemark: startingLocation)
        request.destination   = MKMapItem(placemark: destination)
        request.transportType = .automobile
        
        return request
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude  = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func setupMemberAnnotations(for annotation: MemberAnnotation, on mapView: MKMapView) -> MKAnnotationView? {        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Member", for: annotation)
        guard let markerColor = String.convertToColorFromString(string: annotation.color) else { return nil }
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout    = false
            markerAnnotationView.markerTintColor   = markerColor
        }
        return view
    }
    
    func setupRouteAnnotations(for annotation: RouteAnnotation, on mapView: MKMapView) -> MKAnnotationView? {
        annotation.title = "Route"
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Route", for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.titleVisibility   = .hidden
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.glyphImage        = UIImage(systemName: "flag.checkered.2.crossed")
            markerAnnotationView.markerTintColor   = UIElements.Color.buttonDodgerBlue
            markerAnnotationView.canShowCallout    = true
            markerAnnotationView.leftCalloutAccessoryView = routeDirectionsButton
            routeDirectionsButton.setImage(UIImage(systemName: "arrowshape.turn.up.right.circle.fill"), for: .normal)
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
