//
//  MapHomeViewController+MapViewDelegate.swift
//  MapShare
//
//  Created by iMac Pro on 9/5/23.
//

import MapKit

extension MapHomeViewController: MKMapViewDelegate {
    
    // Provides the coordinates of any change in a user's location and publishes those using WebSockets
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first,
              let currentMember = mapHomeViewModel.mapShareSession?.members.first(where: { Constants.Device.deviceID == $0.deviceID })
        else { return }

        let latitude  = "\(location.coordinate.latitude)"
        let longitude = "\(location.coordinate.longitude)"
        mapHomeViewModel.ablyChannel.publish(currentMember.title, data: "\(latitude):\(longitude)") { error in
            guard error == nil else {
                return print("Publishing Error: \(error?.localizedDescription ?? "Beach Ball of Death")")
            }
        }
    }
    
    // Creates Route and Member annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        if let routeAnnotation = annotation as? Route {
            annotationView = mapHomeViewModel.setupRouteAnnotations(for: routeAnnotation, on: mapView)
            return annotationView
        } else if let member = annotation as? Member {
            annotationView = mapHomeViewModel.setupMemberAnnotations(for: member, on: mapView)
            mapView.showsUserLocation = false
            return annotationView
        }
        return nil
    }
    
    // Triggers the direction request to be shared with all users
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let mapShareSession = mapHomeViewModel.mapShareSession,
              let route           = mapShareSession.routes.first
        else { return }
        
        if let annotation = view.annotation, annotation.isKind(of: Route.self) {
            mapHomeViewModel.service.firestoreShareDirections(forSession: mapShareSession, using: route)
        }
    }
    
    // Customizes the Route directions (color) for each Member
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay  = overlay as? MKPolyline,
              let activeMembers = mapHomeViewModel.mapShareSession?.members.filter ({ $0.isActive }),
              let routeTitle    = routeOverlay.title,
              let markerColor   = activeMembers.first(where: { $0.title == routeTitle })?.color
        else { return MKOverlayRenderer() }
        
        let strokeColor      = Member.convertToColorFromString(string: markerColor)
        let renderer         = MKPolylineRenderer(overlay: routeOverlay)
        renderer.strokeColor = strokeColor
        return renderer
    }
    
    func registerMapAnnotations() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.AnnotationIdentifiers.forRoutes)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.AnnotationIdentifiers.forMembers)
    }
} //: MapViewDelegate
