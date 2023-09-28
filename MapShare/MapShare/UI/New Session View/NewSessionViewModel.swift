//
//  NewSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/1/23.
//

import MapKit

class NewSessionViewModel {
    
    //MARK: - Properties
    var session: Session?
    let service: FirebaseService
    weak var mapDelegate: MapViewController?
    
    var locationManager = CLLocationManager()
    var sessionCode     = ""
    
    init(service: FirebaseService = FirebaseService(), mapDelegate: MapViewController) {
        self.service     = service
        self.mapDelegate = mapDelegate
    }
    
    
    //MARK: - Functions
    func createNewMapShareSession(sessionName: String, sessionCode: String, firstName: String, lastName: String, screenName: String, markerColor: String, organizerLatitude: Double, organizerLongitude: Double) {
        guard let organizerDeviceID = Constants.Device.deviceID else { return }
        let organizerCoordinates    = CLLocationCoordinate2D(latitude: organizerLatitude, longitude: organizerLongitude)
        let organizer               = Member(firstName: firstName,
                                             lastName: lastName,
                                             color: markerColor,
                                             deviceID: organizerDeviceID,
                                             isOrganizer: true,
                                             isActive: true,
                                             coordinate: organizerCoordinates,
                                             title: screenName)
        
        let newSession  = Session(sessionName: sessionName,
                                  sessionCode: generateRandomCode(sessionCode),
                                  organizerDeviceID: organizerDeviceID,
                                  members: [organizer],
                                  routes: [])
        
        session = newSession
        service.firestoreSaveNewSession(newSession: newSession, withMember: organizer) {
            self.mapDelegate?.mapViewModel.delegateUpdateWithSession(session: newSession)
        }
        
        self.sessionCode = ""
    }
    
    private func generateRandomCode(_ sessionCode: String) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var randomString = sessionCode
        
        for _ in 0..<6 {
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            randomString += String(character)
        }
        
        return randomString
    }
}
