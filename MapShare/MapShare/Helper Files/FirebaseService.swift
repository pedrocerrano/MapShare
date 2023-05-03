//
//  FirebaseService.swift
//  MapShare
//
//  Created by iMac Pro on 5/2/23.
//

import Foundation
import FirebaseFirestore

struct FirebaseService {
    
    //MARK: - PROPERTIES
    let ref = Firestore.firestore()
    
    //MARK: - FUNCTIONS
    func saveNewSessionToFirestore(sessionName: String, withOrganizer organizer: Member) {
        let sessionCode = "ABCDEF"
        let sessionUUID = UUID().uuidString
        let newSession  = Session(sessionName: sessionName, sessionUUID: sessionUUID, sessionCode: sessionCode, members: [organizer], isActive: true)
        ref.collection(Session.SessionKey.collectionType).document(newSession.sessionUUID).setData(newSession.sessionDictionaryRepresentation)
    }
    
}
