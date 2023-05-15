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
    func saveNewSessionToFirestore(newSession: Session, withMember: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(newSession.sessionCode).setData(newSession.sessionDictionaryRepresentation)
        ref.collection(Session.SessionKey.sessionCollectionType).document(newSession.sessionCode).collection(Session.SessionKey.membersCollectionType).document(withMember.memberDeviceID).setData(withMember.memberDictionaryRepresentation)
    }
    
    func loadSessionFromFirestore(forSession session: Session, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
        
        var escapingSession: Session?
        
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).getDocument { document, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.firebaseError(error)))
                return
            }
            
            guard let document else { completion(.failure(.noDataFound)) ; return }
            if let newData = document.data() {
                if let session = Session(fromSessionDictionary: newData) {
                    escapingSession = session
                }
            }
        }
        
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.firebaseError(error)))
            }
            
            guard let memberData = snapshot?.documents else { completion(.failure(.noDataFound)) ; return }
            let memberDictArray  = memberData.compactMap { $0.data() }
            let members          = memberDictArray.compactMap { Member(fromMemberDictionary: $0) }
            escapingSession?.members.append(contentsOf: members)
        }
        
        if let escapingSession = escapingSession {
            completion(.success(escapingSession))
        }
    }
    
    func deleteSessionFromFirestore(session: Session) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).delete()
    }
    
    func deleteAllMembersFromFirestore(session: Session, member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).delete()
    }
    
    func searchFirebaseForActiveSession(withCode codeEntered: String, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(codeEntered).getDocument { document, error in
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
        ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).setData([Session.SessionKey.members : FieldValue.arrayUnion([member.memberDictionaryRepresentation])])
        completion()
    }
    
    func listenForChangesToSession(forSession sessionCode: String, forMembers members: [Member], completion: @escaping(Result<Session, FirebaseError>) -> Void) {
        
        var escapingSession: Session?
        
        ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let documentSnapshot else { completion(.failure(.noDataFound)) ; return }
            if let updatedData = documentSnapshot.data() {
                if let updatedSession = Session(fromSessionDictionary: updatedData) {
                    escapingSession = updatedSession
                }
            }
        }
        
        for member in members {
            ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    completion(.failure(.firebaseError(error)))
                }
                
                guard let documentSnapshot else { completion(.failure(.noDataFound)) ; return }
                if let updatedData = documentSnapshot.data() {
                    if let updatedMember = Member(fromMemberDictionary: updatedData) {
                        escapingSession?.members.append(updatedMember)
                    }
                }
            }
        }
        
        if let escapingSession = escapingSession {
            completion(.success(escapingSession))
        }
    }
    
    func admitMemberToActiveSessionOnFirestore(forSession session: Session, forMember member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).updateData([Session.SessionKey.members : FieldValue.arrayUnion([member.memberDictionaryRepresentation])])
        #warning("This CREATES a NEW member and does not update. Need to refactor.")
    }
    
    func deleteMemberFromFirestore(fromSession session: Session, member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).updateData([Session.SessionKey.members : FieldValue.arrayRemove([member.memberDictionaryRepresentation])])
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
        ref.collection(Session.SessionKey.sessionCollectionType).document("HZ5MB0").getDocument { document, error in
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
        ref.collection(Session.SessionKey.sessionCollectionType).document("HZ5MB0").getDocument { document, error in
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
