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
    @IBOutlet weak var addressLabel: UILabel!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        registerMapAnnotations()
        setupModalHomeSheetController()
        checkLocationServices()
        centerViewOnUser()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - IB Actions
    @IBAction func routeButtonTapped(_ sender: Any) {
        guard let annotation = self.annotation else { return }
        getDirections(annotation: annotation )
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
} //: CLASS

extension MapHomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard let previousLocation = self.previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        
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
    
    private func registerMapAnnotations() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: self.identifier)
    }
    
    private func setupCustomAnnotations(for annotation: CustomAnnotation, on mapView: MKMapView) -> MKAnnotationView? {
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
