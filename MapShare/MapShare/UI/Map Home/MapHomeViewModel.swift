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
    func noSessionActive()
}

class MapHomeViewModel {
    
    //MARK: - PROPERTIES
    var service: FirebaseService
    var mapShareSession: Session?
    var routeAnnotation: RouteAnnotation?
    var routeAnnotations: [RouteAnnotation] = []
    var memberAnnotation: MemberAnnotation?
    var memberAnnotations: [MemberAnnotation]
    private weak var delegate: MapHomeViewModelDelegate?
    
    var user: MKUserLocation?
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    let locationManager = CLLocationManager()
        
    let btn = UIButton(type: .detailDisclosure)
    
    init(service: FirebaseService = FirebaseService(), memberAnnotation: MemberAnnotation? = nil, memberAnnotations: [MemberAnnotation] = [], delegate: MapHomeViewModelDelegate) {
        self.service           = service
        self.memberAnnotation  = memberAnnotation
        self.memberAnnotations = memberAnnotations
        self.delegate          = delegate
    }
    
    //MARK: - FIREBASE LISTENER FUNCTIONS
    func updateMapWithSessionChanges() {
        guard let mapShareSession else { return }
        service.listenForChangesToSession(forSession: mapShareSession.sessionCode) { result in
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
                let filteredMembers = loadedMembers.filter { $0.isActive }
                for member in filteredMembers {
                    let memberLocation = MemberAnnotation(member: member,
                                                          coordinate: CLLocationCoordinate2D(latitude: member.currentLocLatitude,
                                                                                             longitude: member.currentLocLongitude),
                                                          title: member.screenName,
                                                          annotationColor: .blue)
                    self.memberAnnotations.append(memberLocation)
                }
                self.delegate?.changesInMembers()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    //MARK: - FIREBASE ROUTE CRUD FUNCTIONS
    func saveRouteToFirestore(newRoute: MSRoute) {
        guard let mapShareSession else { return }
        service.saveNewRouteToFirestore(forSession: mapShareSession, newRoute: newRoute)
    }
    
    func deleteRouteFromFirestore(routeToDelete route: MSRoute) {
        guard let mapShareSession else { return }
        service.deleteRouteOnFirestore(fromSession: mapShareSession, route: route)
    }
    
    
    //MARK: - MAPKIT FUNCTIONS
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, annotation: MKAnnotation) -> MKDirections.Request {
        let routeCoordinate  = annotation.coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination      = MKPlacemark(coordinate: routeCoordinate)
        let request          = MKDirections.Request()
        
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
        annotation.title = annotation.member.screenName
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Member", for: annotation)
        guard let markerColor = String.convertToColorFromString(string: annotation.member.mapMarkerColor) else { return nil }
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
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout    = true
            markerAnnotationView.markerTintColor   = UIColor.black
            btn.setImage(UIImage(systemName: "location"), for: .normal)
            markerAnnotationView.leftCalloutAccessoryView = btn
        }
        return view
    }
    
    func startTrackingLocation(mapView: MKMapView) {
        mapView.showsUserLocation = true
        centerViewOnMember(mapView: mapView)
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func centerViewOnMember(mapView: MKMapView) {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        mapView.setRegion(region, animated: true)
    }
}
