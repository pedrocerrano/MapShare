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
        let organizerUUID           = UUID().uuidString
        guard let organizerDeviceID = Constants.Device.deviceID else { return }
        let organizer               = Member(firstName: firstName,
                                             lastName: lastName,
                                             screenName: screenName,
                                             mapMarkerColor: markerColor,
                                             memberUUID: organizerUUID,
                                             memberDeviceID: organizerDeviceID,
                                             isOrganizer: true,
                                             isActive: true,
                                             currentLocLatitude: organizerLatitude,
                                             currentLocLongitude: organizerLongitude)
        
        let sessionUUID = UUID().uuidString
        let sessionCode = String.generateRandomCode()
        let newSession  = Session(sessionName: sessionName,
                                  sessionUUID: sessionUUID,
                                  sessionCode: sessionCode,
                                  organizerDeviceID: organizerDeviceID,
                                  members: [organizer],
                                  destination: [],
                                  isActive: true)
        
        session = newSession
        service.saveNewSessionToFirestore(newSession: newSession)
    }
    
    func getScottTESTSession() {
        service.forScottTESTING { result in
            switch result {
            case .success(let scottTestSession):
                guard let scottTestSession else { return }
                self.scottTestSession = scottTestSession
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getChaseTESTSession() {
        service.forChaseTESTING { result in
            switch result {
            case .success(let chaseTestSession):
                guard let chaseTestSession else { return }
                self.chaseTestSession = chaseTestSession
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
