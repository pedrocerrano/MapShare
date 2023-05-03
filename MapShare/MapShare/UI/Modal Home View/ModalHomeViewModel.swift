//
//  ModalHomeViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/1/23.
//

import Foundation

class ModalHomeViewModel {
    
    //MARK: - PROPERTIES
    var session: Session?
    var organizer: Member?
    let service: FirebaseService
    
    init(session: Session? = nil, organizer: Member? = nil, service: FirebaseService = FirebaseService()) {
        self.session   = session
        self.organizer = organizer
        self.service   = service
    }
    
    
    //MARK: - FUNCTIONS
    func createNewMapShareSession(sessionName: String, organizerName: String, markerColor: String) {
        let organizerUUID      = UUID().uuidString
        let organizerLatitude  = Double(0.0)
        let organizerLongitude = Double(0.0)
        #warning("Pass in current latitude and longitude for Organizer")
        let organizer          = Member(memberName: organizerName, mapMarkerColor: markerColor, memberUUID: organizerUUID, isOrganizer: true, isActive: true, currentLocLatitude: organizerLatitude, currentLocLongitude: organizerLongitude)
        service.saveNewSessionToFirestore(sessionName: sessionName, withOrganizer: organizer)
        #warning("Will likely need a completion handler")
    }
}
