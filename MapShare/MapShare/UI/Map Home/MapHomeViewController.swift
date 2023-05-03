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
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    let annotation = MKPointAnnotation()
    var previousLocation: CLLocation?
    
    var geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupModalHomeSheetController()
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
        
        annotation.coordinate = coordinate
        print("Annotation Coordinates: \(coordinate)")
        
        if mapView.annotations.count == 1 {
            guard let last = mapView.annotations.last else { return }
            mapView.removeAnnotation(last)
        }
        mapView.addAnnotation(annotation)
    }
    
    func setupModalHomeSheetController() {
        let storyboard = UIStoryboard(name: "ModalHome", bundle: nil)
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
        renderer.strokeColor = .blue
        
        return renderer
    }
} //: MapViewDelegate
