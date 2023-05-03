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
    
    init(session: Session? = nil, organizer: Member? = nil) {
        self.session   = session
        self.organizer = organizer
    }
    
    
    //MARK: - FUNCTIONS
    func createNewMapShareSession(sessionName: String, organizerName: String ) {
        let sessionUUID        = UUID().uuidString
        let organizerUUID      = UUID().uuidString
        let organizerLatitude  = Double(0.0)
        let organizerLongitude = Double(0.0)
        #warning("Pass in current latitude and longitude for Organizer")
        let organizer          = Member(memberName: organizerName, memberUUID: organizerUUID, isOrganizer: true, isActive: true, currentLocLatitude: organizerLatitude, currentLocLongitude: organizerLongitude)
        let newSession         = Session(sessionName: sessionName, sessionUUID: sessionUUID, members: [organizer], isActive: true)
        #warning("Pass this into Firebase")
    }
}
