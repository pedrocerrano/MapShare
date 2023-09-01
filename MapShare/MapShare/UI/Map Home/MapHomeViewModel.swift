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
    func changesInMembers()
    func changesInRoute()
    func noSessionActive()
}

class MapHomeViewModel {
    
    //MARK: - PROPERTIES
    var service: FirebaseService
    var sessionListener: ListenerRegistration?
    var memberListener: ListenerRegistration?
    var deletedMemberListener: ListenerRegistration?
    var routesListener: ListenerRegistration?
    
    var mapShareSession: Session?
    var memberAnnotationToDelete: Member?
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
    func updateSessionChanges() {
        guard let mapShareSession else { return }
        sessionListener = service.firestoreListenToSession(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedSession):
                mapShareSession.isActive          = loadedSession.isActive
                mapShareSession.sessionCode       = loadedSession.sessionCode
                mapShareSession.sessionName       = loadedSession.sessionName
                mapShareSession.organizerDeviceID = loadedSession.organizerDeviceID
            case .failure(let error):
                self.delegate?.noSessionActive()
                print(error.localizedDescription, "MapHomeViewModel: Issue with the Session data")
            }
        }
    }
    
    func updateMemberChanges() {
        guard let mapShareSession else { return }
        memberListener = service.firestoreListenToMembers(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedMembers):
                mapShareSession.members = loadedMembers
                self.delegate?.changesInMembers()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: Issue with the Members data")
            }
        }
    }
    
    func updateRouteChanges() {
        guard let mapShareSession else { return }
        routesListener = service.firestoreListenToRoutes(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedRoute):
                mapShareSession.route = loadedRoute
                self.delegate?.changesInRoute()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: Issue with the Routes data")
            }
        }
    }
    
    func updateAnnotationsForDeletedMember() {
        guard let mapShareSession else { return }
        deletedMemberListener = service.firestoreListenForDeletedMembers(forSession: mapShareSession) { result in
            switch result {
            case .success(let deletedMembers):
                mapShareSession.deletedMembers = deletedMembers
                self.delegate?.changesInMembers()
                if !mapShareSession.route.isEmpty {
                    self.delegate?.changesInRoute()
                }
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: Issue with the DeletedMembers")
            }
        }
    }
    
    
    //MARK: - FIREBASE ROUTE CRUD FUNCTIONS
    func saveRouteToFirestore(newRoute: Route) {
        guard let mapShareSession else { return }
        service.firestoreSaveNewRoute(forSession: mapShareSession, route: newRoute)
    }
    
    func deleteRouteFromFirestore() {
        guard let mapShareSession else { return }
        service.firestoreDeleteRoute(fromSession: mapShareSession)
    }
    
    func updateMemberTravelTime(withMemberID deviceID: String, withTravelTime travelTime: Double) {
        guard let mapShareSession else { return }
        service.firestoreUpdateRouteTravelTime(forSession: mapShareSession, withMemberID: deviceID, withTime: travelTime)
    }
    
    func updateToDriving() {
        guard let mapShareSession,
              let route = mapShareSession.route.first else { return }
        service.firestoreUpdateRouteToDriving(forSession: mapShareSession, forRoute: route)
    }
    
    func updateToWalking() {
        guard let mapShareSession,
              let route = mapShareSession.route.first else { return }
        service.firestoreUpdateRouteToWalking(forSession: mapShareSession, forRoute: route)
    }
    
    func clearFirebaseDeletedMemberAfterRemovingAnnotation(for deletedMember: DeletedMember) {
        guard let mapShareSession else { return }
        service.firestoreClearDeletedMembers(fromSession: mapShareSession, forDeletedMember: deletedMember)
    }
    
    func updateMemberLocation(forMember member: Member, withLatitude: Double, withLongitude: Double) {
        // This is the function to update Real-Time Location update with Ably
    }
    
    
    //MARK: - MAPKIT FUNCTIONS
    func toggleTravelMethod(for button: UIButton) {
        guard let drivingImage = UIImage(systemName: SFSymbols.driving),
              let walkingImage = UIImage(systemName: SFSymbols.walking)
        else { return }
        
        if isDriving {
            isDriving.toggle()
            updateToWalking()
            button.setImage(drivingImage, for: .normal)
        } else {
            isDriving.toggle()
            updateToDriving()
            button.setImage(walkingImage, for: .normal)
        }
    }
    
    func shareDirections() {
        routeDirectionsButton.addTarget(self, action: #selector(routeButtonPressed), for: .touchUpInside)
    }
    
    @objc func routeButtonPressed() {
        guard let mapShareSession else { return }
        service.firestoreShareDirections(forSession: mapShareSession, using: mapShareSession.route[0])
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
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationIdentifiers.forMembers, for: member)
        guard let markerColor = Member.convertToColorFromString(string: member.color) else { return nil }
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout    = false
            markerAnnotationView.markerTintColor   = markerColor
        }
        return view
    }
    
    func setupRouteAnnotations(for routeAnnotation: Route, on mapView: MKMapView) -> MKAnnotationView? {
        routeAnnotation.title = Constants.AnnotationIdentifiers.forRoutes
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationIdentifiers.forRoutes, for: routeAnnotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.titleVisibility   = .hidden
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.glyphImage        = UIImage(systemName: SFSymbols.routeAnnotationImage)
            markerAnnotationView.markerTintColor   = UIElements.Color.dodgerBlue
            markerAnnotationView.canShowCallout    = true
            routeDirectionsButton.setImage(UIImage(systemName: SFSymbols.routeAnnotationButton), for: .normal)
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
