//
//  FirebaseService.swift
//  MapShare
//
//  Created by iMac Pro on 5/2/23.
//

import Foundation
import FirebaseFirestore

enum FirebaseError: Error {
    case firebaseError(Error)
    case unableToDecode
    case noDataFound
}

struct FirebaseService {
    
    //MARK: - PROPERTIES
    let ref = Firestore.firestore()
    
    //MARK: - FUNCTIONS
    func saveNewSessionToFirestore(newSession: Session) {
        ref.collection(Session.SessionKey.collectionType).document(newSession.sessionCode).setData(newSession.sessionDictionaryRepresentation)
    }
    
    func loadSessionFromFirestore(forSession session: Session, completion: @escaping(Result<Session?, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document(session.sessionCode).getDocument { document, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.firebaseError(error)))
                return
            }
            
            guard let document else { completion(.failure(.noDataFound)) ; return }
            let session = document.data().map { Session(fromSessionDictionary: $0) }
            guard let session else { return }
            completion(.success(session))
        }
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
