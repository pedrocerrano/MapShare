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
    
    init(session: Session? = nil) {
        self.session = session
    }
    
    
    //MARK: - FUNCTIONS
    func createNewMapShareSession() {
        let name = "Untitled MapShare"
        let uuid = UUID().uuidString
        let newSession = Session(sessionName: name, sessionUUID: uuid, members: [], isActive: false)
        session = newSession
    }
    
//    func createNewMapShareSession(session: Session) {
//        let name = "Untitled MapShare"
//        let uuid = UUID().uuidString
//        let newSession = Session(sessionName: name, sessionUUID: uuid, members: session.members, isActive: false)
//        session = newSession
//    }
}
