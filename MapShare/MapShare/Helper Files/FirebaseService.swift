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
    
    func loadSessionFromFirestore(forSession session: Session, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document(session.sessionCode).getDocument { document, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.firebaseError(error)))
                return
            }
            
            guard let document else { completion(.failure(.noDataFound)) ; return }
            if let newData = document.data() {
                if let session = Session(fromSessionDictionary: newData) {
                    completion(.success(session))
                }
            }
        }
    }
    
    func deleteSessionFromFirestore(session: Session) {
        ref.collection(Session.SessionKey.collectionType).document(session.sessionCode).delete()
    }
    
    func searchFirebaseForActiveSession(withCode codeEntered: String, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document(codeEntered).getDocument { document, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let document else { completion(.failure(.noDataFound)) ; return }
            if let newData = document.data() {
                if let session = Session(fromSessionDictionary: newData) {
                    completion(.success(session))
                }
            }
        }
    }
    
    func appendMemberToSessionOnFirestore(withCode sessionCode: String, member: Member, completion: @escaping() -> Void) {
        ref.collection(Session.SessionKey.collectionType).document(sessionCode).updateData([Session.SessionKey.members : FieldValue.arrayUnion([member.memberDictionaryRepresentation])])
        completion()
    }
    
    func listenForChangesToSession(forSession sessionCode: String, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document(sessionCode).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let documentSnapshot else { completion(.failure(.noDataFound)) ; return }
            if let updatedData = documentSnapshot.data() {
                if let updatedSession = Session(fromSessionDictionary: updatedData) {
                    completion(.success(updatedSession))
                }
            }
        }
    }
    
    func admitMemberToActiveSessionOnFirestore(forSession session: Session, forMember member: Member) {
        ref.collection(Session.SessionKey.collectionType).document(session.sessionCode).updateData([Session.SessionKey.members : FieldValue.arrayUnion([member.memberDictionaryRepresentation])])
    }
    
    func deleteMemberFromFirestore(fromSession session: Session, member: Member) {
        ref.collection(Session.SessionKey.collectionType).document(session.sessionCode).updateData([Session.SessionKey.members : FieldValue.arrayRemove([member.isActive])])
    }
    
    func saveNewDestinationToFirestore() {
        
    }
    
    func updateDestinationOnFirestore() {
        
    }
    
    func deleteDestinationOnFirestore() {
        
    }
    
    func updateLocationOfMemberToFirestore() {
        
    }
    
    func forScottTESTING(completion: @escaping(Result<Session?, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document("HZ5MB0").getDocument { document, error in
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
    
    func forChaseTESTING(completion: @escaping(Result<Session?, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.collectionType).document("HZ5MB0").getDocument { document, error in
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
