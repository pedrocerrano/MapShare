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
        let sessionUUID = UUID().uuidString
        let sessionCode = String.generateRandomCode()
        let newSession  = Session(sessionName: sessionName, sessionUUID: sessionUUID, sessionCode: sessionCode, members: [organizer], destination: [], isActive: true)
        ref.collection(Session.SessionKey.collectionType).document(newSession.sessionCode).setData(newSession.sessionDictionaryRepresentation)
    }
    
    func loadSessionFromFirestore() {
        
    }
    
    func addMemberToSessionOnFirestore() {
        
    }
    
    func deleteMemberFromFirestore() {
        
    }
    
    func deleteSessionFromFirestore() {
        
    }
    
    func saveNewDestinationToFirestore() {
        
    }
    
    func updateDestinationOnFirestore() {
        
    }
    
    func deleteDestinationOnFirestore() {
        
    }
    
    func updateLocationOfMemberToFirestore() {
        
    }
}
