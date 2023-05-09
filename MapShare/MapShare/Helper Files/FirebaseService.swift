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
    
    func deleteSessionFromFirestore(session: Session) {
        ref.collection(Session.SessionKey.collectionType).document(session.sessionCode).delete()
    }
    
    func searchFirebaseForActiveSession(withCode codeEntered: String, completion: @escaping(Result<Bool, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document(codeEntered).getDocument { document, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let document else { completion(.failure(.noDataFound)) ; return }
            let session = document.data().map { Session(fromSessionDictionary: $0) }
            guard let session else { completion(.success(false)) ; return }
            if session?.sessionCode == codeEntered {
                completion(.success(true))
            }
        }
    }
    
    func addMemberToSessionOnFirestore(withCode sessionCode: String, member: Member, completion: @escaping() -> Void) {
        ref.collection(Session.SessionKey.collectionType).document(sessionCode).updateData([Session.SessionKey.members : FieldValue.arrayUnion([member.memberDictionaryRepresentation])])
        completion()
    }
    
    func deleteMemberFromFirestore() {
        
    }
    
    func saveNewDestinationToFirestore() {
        
    }
    
    func updateDestinationOnFirestore() {
        
    }
    
    func deleteDestinationOnFirestore() {
        
    }
    
    func updateLocationOfMemberToFirestore() {
        
    }
    
    func forTESTING(completion: @escaping(Result<Session?, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document("9486YS").getDocument { document, error in
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
}
