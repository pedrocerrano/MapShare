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
    
    init(service: FirebaseService = FirebaseService(), mapHomeDelegate: MapHomeViewController) {
        self.service         = service
        self.mapHomeDelegate = mapHomeDelegate
    }
    
    
    //MARK: - FUNCTIONS
    func createNewMapShareSession(sessionName: String, firstName: String, lastName: String, screenName: String, markerColor: String, organizerLatitude: Double, organizerLongitude: Double) {
        guard let organizerDeviceID = Constants.Device.deviceID else { return }
        let organizer               = Member(firstName: firstName,
                                             lastName: lastName,
                                             screenName: screenName,
                                             mapMarkerColor: markerColor,
                                             memberDeviceID: organizerDeviceID,
                                             isOrganizer: true,
                                             isActive: true,
                                             currentLocLatitude: organizerLatitude,
                                             currentLocLongitude: organizerLongitude)
        
        let sessionCode = String.generateRandomCode()
        let newSession  = Session(sessionName: sessionName,
                                  sessionCode: sessionCode,
                                  organizerDeviceID: organizerDeviceID,
                                  members: [organizer],
                                  destination: [],
                                  isActive: true)
        
        session = newSession
        mapHomeDelegate?.delegateUpdateWithSession(session: newSession)
        service.saveNewSessionToFirestore(newSession: newSession, withMember: organizer)
    }
}
