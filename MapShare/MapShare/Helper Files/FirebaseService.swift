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
    case sessionReturnedNil
}

struct FirebaseService {
    
    //MARK: - PROPERTIES
    let ref = Firestore.firestore()
    
    
    //MARK: - SESSION and MEMBER CRUD FUNCTIONS
    func saveNewSessionToFirestore(newSession: Session, withMember: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(newSession.sessionCode).setData(newSession.sessionDictionaryRepresentation)
        ref.collection(Session.SessionKey.sessionCollectionType).document(newSession.sessionCode).collection(Session.SessionKey.membersCollectionType).document(withMember.memberDeviceID).setData(withMember.memberDictionaryRepresentation)
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
            } else {
                completion(.failure(.sessionReturnedNil))
            }
        }
    }
    
    func appendMemberToSessionOnFirestore(withCode sessionCode: String, member: Member, completion: @escaping() -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).setData(member.memberDictionaryRepresentation)
        completion()
    }
    
    func admitMemberToActiveSessionOnFirestore(forSession session: Session, forMember member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).updateData([Member.MemberKey.isActive : true])
    }
    
    func deleteMemberFromFirestore(fromSession session: Session, member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).delete()
    }
    
    func updateLocationOfMemberToFirestore() {
        #warning("This is where the Push Location code will go")
    }
    
    
    //MARK: - ROUTE CRUD FUNCTIONS
    func saveNewRouteToFirestore(forSession session: Session, routeAnnotation: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).setData(routeAnnotation.routeAnnotationDictionaryRepresentation)
    }
    
    func deleteRouteOnFirestore(fromSession session: Session) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).delete()
    }
    
    func showDirectionsToMembers(forSession session: Session, using routeAnnotation: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).updateData([RouteAnnotation.RouteAnnotationKey.isShowingDirections : true])
    }
    
    
    //MARK: - LISTENERS
    func listenForChangesToSession(forSession sessionCode: String, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let documentSnapshot else { completion(.failure(.noDataFound)) ; return }
            if let updatedData = documentSnapshot.data() {
                if let updatedSession = Session(fromSessionDictionary: updatedData) {
                    completion(.success(updatedSession))
                }
            } else {
                completion(.failure(.sessionReturnedNil))
            }
        }
    }
    
    func listenForChangesToMembers(forSession session: Session, completion: @escaping(Result<[Member], FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
         
            guard let documentsData = querySnapshot?.documents else { completion(.failure(.noDataFound)) ; return }
            let memberDictArray     = documentsData.compactMap { $0.data() }
            let members             = memberDictArray.compactMap { Member(fromMemberDictionary: $0) }
            completion(.success(members))
        }
    }
    
    func listenToChangesForRoutes(forSession session: Session, completion: @escaping(Result<[RouteAnnotation], FirebaseError>) -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let documentsData = querySnapshot?.documents else { completion(.failure(.noDataFound)) ; return }
            let routeDictArray      = documentsData.compactMap { $0.data() }
            let routeAnnotations    = routeDictArray.compactMap { RouteAnnotation(fromRouteAnnotationDictionary: $0) }
            completion(.success(routeAnnotations))
        }
    }
}
