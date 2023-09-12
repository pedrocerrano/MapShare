//
//  MapHomeViewModel+MapKitFuncs.swift
//  MapShare
//
//  Created by iMac Pro on 9/5/23.
//

import UIKit
import MapKit
import CoreLocation

extension MapHomeViewModel {
    
    //MARK: - Route and Directions Functions
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
        service.firestoreShareDirections(forSession: mapShareSession, using: mapShareSession.routes[0])
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
    
    
    //MARK: - Annotations Functions
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
            markerAnnotationView.markerTintColor   = UIColor.dodgerBlue()
            markerAnnotationView.canShowCallout    = true
            routeDirectionsButton.setImage(UIImage(systemName: SFSymbols.routeAnnotationButton), for: .normal)
            markerAnnotationView.rightCalloutAccessoryView = routeDirectionsButton
        }
        return view
    }
    
    func clearRouteAnnotations(forMapView mapView: MKMapView, centerRouteButton: UIButton, clearRouteAnnotationsButton: UIButton, travelMethodButton: UIButton) {
        let routeAnnotations = mapView.annotations.filter { !($0 is Member) }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        deleteRouteFromFirestore()
        centerRouteButton.isHidden           = true
        travelMethodButton.isHidden          = true
        clearRouteAnnotationsButton.isHidden = true
        mapShareSession?.routes = []
        
        guard let activeMembers = mapShareSession?.members else { return }
        if activeMembers.count == 1 {
            resetZoomForSingleMember(mapView: mapView)
        } else {
            let memberAnnotations = mapView.annotations.filter { ($0 is Member) }
            mapView.showAnnotations(memberAnnotations, animated: true)
        }
        
        for member in activeMembers {
            updateMemberTravelTime(withMemberID: member.deviceID, withTravelTime: -1)
        }
    }
    
    
    //MARK: - Location and Zoom Functions
    func startTrackingLocation(mapView: MKMapView) {
        mapView.showsUserLocation = true
        resetZoomForSingleMember(mapView: mapView)
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude  = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func resetZoomForSingleMember(mapView: MKMapView) {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        mapView.setRegion(region, animated: true)
    }
    
    func resetZoomForAllMembers(mapView: MKMapView) {
        guard let members = mapShareSession?.members else { return }
        let activeMembers = members.filter { $0.isActive }
        if activeMembers.count > 1 {
            mapView.showAnnotations(activeMembers, animated: true)
        }
    }
    
    func resetZoomToCenterMembers(forMapView mapView: MKMapView, centerLocationButton: UIButton) {
        guard let singleMember    = UIImage(systemName: SFSymbols.singleMember),
              let multipleMembers = UIImage(systemName: SFSymbols.multipleMembers)
        else { return }
        
        if mapShareSession == nil {
            resetZoomForSingleMember(mapView: mapView)
        } else {
            guard let activeMembers = mapShareSession?.members else { return }
            if activeMembers.count >= 2 {
                if zoomAllMembers == false {
                    zoomAllMembers.toggle()
                    resetZoomForAllMembers(mapView: mapView)
                    centerLocationButton.setImage(singleMember, for: .normal)
                } else {
                    zoomAllMembers.toggle()
                    resetZoomForSingleMember(mapView: mapView)
                    centerLocationButton.setImage(multipleMembers, for: .normal)
                }
            } else {
                resetZoomForSingleMember(mapView: mapView)
            }
        }
    }
    
    func resetZoomForSingleMemberRoute(forMapView mapView: MKMapView) {
        guard let currentUser  = mapShareSession?.members.first(where: { $0.deviceID == Constants.Device.deviceID }),
              let userPolyline = mapView.overlays.first(where: { $0.title == currentUser.title })
        else { return }
        
        mapView.setVisibleMapRect(userPolyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 200, right: 80), animated: true)
    }
    
    func resetZoomForAllMembersRoutes(forMapView mapView: MKMapView) {
        guard let polylineOverlay = mapView.overlays.first else { return }
        let newMapRect            = mapView.overlays.reduce(polylineOverlay.boundingMapRect, { $0.union($1.boundingMapRect)} )
        mapView.setVisibleMapRect(newMapRect, edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 200, right: 80), animated: true)
    }
    
    func resetZoomToCenterRoute(forMapView mapView: MKMapView, centerRouteButton: UIButton) {
        guard let singleRoute    = UIImage(systemName: SFSymbols.singleRoute),
              let multipleRoutes = UIImage(systemName: SFSymbols.multipleRoutes)
        else { return }
        
        if zoomAllRoutes == false {
            zoomAllRoutes.toggle()
            resetZoomForAllMembersRoutes(forMapView: mapView)
            centerRouteButton.setImage(singleRoute, for: .normal)
        } else {
            zoomAllRoutes.toggle()
            resetZoomForSingleMemberRoute(forMapView: mapView)
            centerRouteButton.setImage(multipleRoutes, for: .normal)
        }
    }
}
