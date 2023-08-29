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
    func firestoreSaveNewSession(newSession session: Session, withMember member: Member, completion: @escaping () -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).setData(session.sessionDictionaryRepresentation)
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.deviceID).setData(member.memberDictionaryRepresentation)
        completion()
    }
    
    func firestoreSearchForActiveSession(withCode codeEntered: String, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
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
    
    func firestoreJoinNewMember(withCode sessionCode: String, withMember member: Member, completion: @escaping() -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.deviceID).setData(member.memberDictionaryRepresentation)
        completion()
    }
    
    func firestoreAdmitMember(forSession session: Session, forMember member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.deviceID).updateData([Member.MemberKey.isActive : true])
    }
    
    func firestoreDeleteSession(session: Session) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).delete()
    }
    
    func firestoreDeleteMember(fromSession session: Session, withMember member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.deviceID).delete()
    }
    
    
    //MARK: - ROUTE ANNOTATIONS CRUD FUNCTIONS
    func firestoreSaveNewRoute(forSession session: Session, routeAnnotation: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).setData(routeAnnotation.routeAnnotationDictionaryRepresentation)
    }
    
    func firestoreDeleteRoute(fromSession session: Session) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).delete()
    }
    
    func firestoreShareDirections(forSession session: Session, using routeAnnotation: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).updateData([RouteAnnotation.RouteAnnotationKey.isShowingDirections : true])
    }
    
    func firestoreUpdateTravelTime(forSession session: Session, withMemberID deviceID: String, withTime travelTime: Double) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(deviceID).updateData([Member.MemberKey.expectedTravelTime : travelTime])
    }
    
    func firestoreUpdateTransportTypeToDriving(forSession session: Session, forRoute route: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).updateData([RouteAnnotation.RouteAnnotationKey.isDriving : true])
    }
    
    func firestoreUpdateTransportTypeToWalking(forSession session: Session, forRoute route: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).updateData([RouteAnnotation.RouteAnnotationKey.isDriving : false])
    }

    
    //MARK: - LISTENERS
    func firestoreListenToSession(forSession session: Session, completion: @escaping(Result<Session, FirebaseError>) -> Void) -> ListenerRegistration {
        let sessionListener = ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).addSnapshotListener { documentSnapshot, error in
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
        
        return sessionListener
    }
    
    func firestoreListenToMembers(forSession session: Session, completion: @escaping(Result<[Member], FirebaseError>) -> Void) -> ListenerRegistration {
        let memberListener = ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
         
            guard let documentsData = querySnapshot?.documents else { completion(.failure(.noDataFound)) ; return }
            let memberDictArray     = documentsData.compactMap { $0.data() }
            let members             = memberDictArray.compactMap { Member(fromMemberDictionary: $0) }
            completion(.success(members))
        }
        
        return memberListener
    }
    
    func firestoreListenToRoutes(forSession session: Session, completion: @escaping(Result<[RouteAnnotation], FirebaseError>) -> Void) -> ListenerRegistration {
        let routesListener = ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let documentsData = querySnapshot?.documents else { completion(.failure(.noDataFound)) ; return }
            let routeDictArray      = documentsData.compactMap { $0.data() }
            let routeAnnotations    = routeDictArray.compactMap { RouteAnnotation(fromRouteAnnotationDictionary: $0) }
            completion(.success(routeAnnotations))
        }
        
        return routesListener
    }
}
