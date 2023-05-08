//
//  MapHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/25/23.
//

import MapKit
import UIKit
import CoreLocation
import CoreLocationUI

class MapHomeViewController: UIViewController {
        
    // MARK: - Properties
    var geoCoder = CLGeocoder()
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    
    var annotation: CustomAnnotation?
    var customAnnotations: [CustomAnnotation] = []
    
    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
//        setupModalHomeSheetController()
        checkLocationServices()
        centerViewOnUser()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - IB Actions
    @IBAction func routeButtonTapped(_ sender: Any) {
        getDirections()
    }
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        centerViewOnUser()
    }
    
    //MARK: - FUNCTIONS
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = CustomAnnotation(coordinate: coordinate, title: nil, subtitle: nil)
        
        annotation.coordinate = coordinate
        print("Annotation Coordinates: \(coordinate)")
        customAnnotations.append(annotation)

        if customAnnotations.count > 1 {
            customAnnotations.removeFirst()
            mapView.removeAnnotation(annotation)
        }
        mapView.addAnnotation(annotation)
    }
    
//    func setupModalHomeSheetController() {
//        let storyboard = UIStoryboard(name: "NewSession", bundle: nil)
//        guard let sheetController = storyboard.instantiateViewController(withIdentifier: "NewSessionVC") as? NewSessionViewController else { return }
//        sheetController.isModalInPresentation = true
//        self.parent?.present(sheetController, animated: true, completion: nil)
//    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUser() {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        mapView.setRegion(region, animated: true)
    }
    
    func checkLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.setUpLocationManager()
                self.checkLocationServices()
            } else {
                // Note: - Show alert letting the user know they have to turn this on...
            }
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func startTrackingLocation() {
        mapView.showsUserLocation = true
        centerViewOnUser()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Note: - Show an alert instructing how to turn on permissions.
            break
        case .denied:
            // Note: - Show an alert instructing how to turn on permissions.
            break
        case .authorizedAlways:
            startTrackingLocation()
        case .authorizedWhenInUse:
            startTrackingLocation()
        @unknown default:
            break
        }
    }
    
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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
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
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
} //: CLASS

extension MapHomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
} //: LocationManagerDelegate

extension MapHomeViewController: UIPopoverPresentationControllerDelegate {
    func showDetails(from view: UIView) {
        let annotationViewPopover = CustomAnnotationViewController()
        let popOver = annotationViewPopover.popoverPresentationController
        popOver?.sourceView = view
        popOver?.delegate = self
        present(annotationViewPopover, animated: true, completion: nil)
    }
} //: PopoverDelegate

extension MapHomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.setSelected(true, animated: true)
        if view.annotation is CustomAnnotation {
            showDetails(from: view)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

        let identifier = "Route"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let destination = view.annotation as? CustomAnnotation else { return }
        let name = destination.title
        let info = destination.subtitle
        
        let ac = UIAlertController(title: name, message: info, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)

        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] placemarks, _ in
            guard let self = self else { return }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .cyan
        
        return renderer
    }
} //: MapViewDelegate
