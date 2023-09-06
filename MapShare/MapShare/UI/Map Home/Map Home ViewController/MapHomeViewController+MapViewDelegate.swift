//
//  MapHomeViewController+MapViewDelegate.swift
//  MapShare
//
//  Created by iMac Pro on 9/5/23.
//

import MapKit

extension MapHomeViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let mapShareSession = mapHomeViewModel.mapShareSession else { return }
        if let annotation = view.annotation, annotation.isKind(of: Route.self) {
            mapHomeViewModel.service.firestoreShareDirections(forSession: mapShareSession, using: mapShareSession.routes[0])
        }
    }
    
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
