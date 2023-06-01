//
//  LocationPushService.swift
//  LocationPush
//
//  Created by iMac Pro on 5/30/23.
//

import CoreLocation

class LocationPushService: NSObject, CLLocationPushServiceExtension, CLLocationManagerDelegate {

    //MARK: - PROPERTIES
    var completion: (() -> Void)?
    var locationManager: CLLocationManager?
    
    //MARK: - FUNCTIONS
    func didReceiveLocationPushPayload(_ payload: [String : Any], completion: @escaping () -> Void) {
        self.completion = completion
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.requestLocation()
    }
    
    func serviceExtensionWillTerminate() {
        // Called just before the extension will be terminated by the system.
        self.completion?()
    }

    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.first
       
        
        // If sharing the locations to another user, end-to-end encrypt them to protect privacy
        
        // When finished, always call completion()
        self.completion?()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.completion?()
    }

}
