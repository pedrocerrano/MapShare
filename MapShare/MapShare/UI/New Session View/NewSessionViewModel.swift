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
    
    init(session: Session? = nil, service: FirebaseService = FirebaseService()) {
        self.session   = session
        self.service   = service
    }
    
    
    //MARK: - FUNCTIONS
    func createNewMapShareSession(sessionName: String, firstName: String, lastName: String, screenName: String, markerColor: String, organizerLatitude: Double, organizerLongitude: Double) {
        let organizerUUID  = UUID().uuidString
        let organizer = Member(firstName: firstName,
                               lastName: lastName,
                               screenName: screenName,
                               mapMarkerColor: markerColor,
                               memberUUID: organizerUUID,
                               isOrganizer: true,
                               isActive: true,
                               currentLocLatitude: organizerLatitude,
                               currentLocLongitude: organizerLongitude)
        
        let sessionUUID = UUID().uuidString
        let sessionCode = String.generateRandomCode()
        let newSession = Session(sessionName: sessionName,
                                 sessionUUID: sessionUUID,
                                 sessionCode: sessionCode,
                                 members: [organizer],
                                 destination: [],
                                 isActive: true)
        
        session = newSession
        service.saveNewSessionToFirestore(newSession: newSession)
    }
}
