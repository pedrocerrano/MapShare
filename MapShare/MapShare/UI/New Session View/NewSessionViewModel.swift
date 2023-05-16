//
//  NewSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/1/23.
//

import Foundation

class NewSessionViewModel {
    
    //MARK: - PROPERTIES
    var session: Session?
    let service: FirebaseService
    
    var scottTestSession: Session?
    var chaseTestSession: Session?
    
    init(session: Session? = nil, service: FirebaseService = FirebaseService(), scottTestSession: Session? = nil, chaseTestSession: Session? = nil) {
        self.session   = session
        self.service   = service
        self.scottTestSession = scottTestSession
        self.chaseTestSession = chaseTestSession
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
        service.saveNewSessionToFirestore(newSession: newSession, withMember: organizer)
    }
}
