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
        let uuid = UUID().uuidString
        let newSession = Session(sessionName: sessionName, sessionUUID: uuid, members: [], isActive: true)
    }
}
