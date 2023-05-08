//
//  CustomAnnotationViewController.swift
//  MapShare
//
//  Created by Chase on 5/8/23.
//

import UIKit
import MapKit

class CustomAnnotationViewController: UIViewController {
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let mapHome = MapHomeViewController()
    var annotation: CustomAnnotation?

    // MARK: - Actions
    @IBAction func routeButtonTapped(_ sender: Any) {
        getDirections()
    }
    
    // MARK: - Functions
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            // Note: - Inform User that we don't have their current location.
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { response, error in
            if let error = error {
                print(error.localizedDescription) ; return
            }
            
            guard let response = response else { return }
            
            for route in response.routes {
                self.mapHome.mapView.addOverlay(route.polyline)
                self.mapHome.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        guard let annotation = annotation else { return MKDirections.Request() }
        
        let destinationCoordinate = annotation.coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapHome.mapView.removeOverlays(mapHome.mapView.overlays)
        mapHome.directionsArray.append(directions)
        let _ = mapHome.directionsArray.map { $0.cancel() }
    }
}
