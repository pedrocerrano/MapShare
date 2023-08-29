//
//  NewSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/1/23.
//

import MapKit

class NewSessionViewModel {
    
    //MARK: - PROPERTIES
    var locationManager = CLLocationManager()
    var session: Session?
    let service: FirebaseService
    weak var mapHomeDelegate: MapHomeViewController?
    var sessionCode = String.generateRandomCode()
    
    init(service: FirebaseService = FirebaseService(), mapHomeDelegate: MapHomeViewController) {
        self.service         = service
        self.mapHomeDelegate = mapHomeDelegate
    }
    
    
    //MARK: - FUNCTIONS
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
                                  sessionCode: sessionCode,
                                  organizerDeviceID: organizerDeviceID,
                                  members: [organizer],
                                  routeAnnotations: [],
                                  isActive: true)
        
        session = newSession
        service.firestoreSaveNewSession(newSession: newSession, withMember: organizer) {
            self.mapHomeDelegate?.delegateUpdateWithSession(session: newSession)
        }
        
        self.sessionCode = String.generateRandomCode()
    }
}
