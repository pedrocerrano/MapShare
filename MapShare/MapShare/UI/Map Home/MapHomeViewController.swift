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
    let identifier = "Route"
    let btn = UIButton(type: .detailDisclosure)
    
    var annotation: CustomAnnotation?
    var customAnnotations: [CustomAnnotation] = []
    
    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        registerMapAnnotations()
        setupModalHomeSheetController()
        centerViewOnUser()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
        locationManagerDidChangeAuthorization(locationManager)
    }
    
    // MARK: - IB Actions
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        centerViewOnUser()
    }
    
    //MARK: - FUNCTIONS
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = CustomAnnotation(coordinate: coordinate, title: nil, subtitle: nil)
        
        annotation.coordinate = coordinate
        customAnnotations.append(annotation)
        
        if customAnnotations.count > 1 {
            mapView.removeAnnotations(customAnnotations)
            mapView.addAnnotation(annotation)
        } else {
            mapView.addAnnotation(annotation)
        }
    }
    
    func setupModalHomeSheetController() {
        let storyboard = UIStoryboard(name: "NewSession", bundle: nil)
        guard let sheetController = storyboard.instantiateViewController(withIdentifier: "NewSessionVC") as? NewSessionViewController else { return }
        sheetController.isModalInPresentation = true
        self.parent?.present(sheetController, animated: true, completion: nil)
    }
    
    func centerViewOnUser() {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        mapView.setRegion(region, animated: true)
    }
    
    func checkLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            } else {
                self.alertLocationAccessNeeded()
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
    
    @objc func getDirections(annotation: MKAnnotation) {
        guard let location = locationManager.location?.coordinate else {
            // Note: - Inform User that we don't have their current location.
            return
        }
        let request = createDirectionsRequest(from: location, annotation: annotation)
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
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, annotation: MKAnnotation) -> MKDirections.Request {
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
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            alertLocationAccessNeeded()
            break
        case .authorizedWhenInUse:
            startTrackingLocation()
            break
        default:
            break
        }
    }
} //: LocationManagerDelegate

extension MapHomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? CustomAnnotation {
             annotationView = setupCustomAnnotations(for: annotation, on: mapView)
        }
    
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .cyan
        
        return renderer
    }
    
    func registerMapAnnotations() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: self.identifier)
    }
    
    func setupCustomAnnotations(for annotation: CustomAnnotation, on mapView: MKMapView) -> MKAnnotationView? {
        annotation.title = "Route"
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: self.identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.markerTintColor = UIColor.purple
            btn.setImage(UIImage(systemName: "location"), for: .normal)
            markerAnnotationView.leftCalloutAccessoryView = btn
        }
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let customAnnotation = view.annotation, customAnnotation.isKind(of: CustomAnnotation.self) {
            print("tapped location accessory button")
            getDirections(annotation: customAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if annotation.isKind(of: CustomAnnotation.self) {
            self.annotation = (annotation as! CustomAnnotation)
        }
    }
} //: MapViewDelegate
