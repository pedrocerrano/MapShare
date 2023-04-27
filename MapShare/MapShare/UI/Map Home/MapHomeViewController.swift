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
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    
    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setupModalHomeSheetController()
        configureLocation()
        createButton()
    }

    
    //MARK: - FUNCTIONS
    func setupModalHomeSheetController() {
        let storyboard = UIStoryboard(name: "ModalHome", bundle: nil)
        guard let sheetController = storyboard.instantiateViewController(withIdentifier: "ModalHomeVC") as? ModalHomeViewController else { return }
        sheetController.isModalInPresentation = true
        self.parent?.present(sheetController, animated: true, completion: nil)
    }
    
    private func createButton() {
        let button = CLLocationButton(frame: CGRect(x: 20, y: 70, width: 40, height: 40))
        button.icon = .arrowOutline
        button.cornerRadius = 12
        view.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        locationManager.startUpdatingLocation()
        guard let current = locationManager.location?.coordinate else { return }
        zoomToCurrent(with: current)
    }
    
    private func configureLocation() {
        locationManager.delegate = self
        switch locationManager.authorizationStatus {
        case .restricted, .denied:
            #warning("Come back to this to handle what the user should see/do if they initially deny it.")
            locationManager.requestLocation()
        case .authorizedWhenInUse, .authorizedAlways:
            beginLocationUpdates(locationManager: locationManager)
        default:
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func zoomToCurrent(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(zoomRegion, animated: true)
    }
} //: CLASS

extension MapHomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        self.locationManager.stopUpdatingLocation()
        
        mapView.setRegion(MKCoordinateRegion(center: latestLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
    }
}
