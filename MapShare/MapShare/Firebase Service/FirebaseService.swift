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
    
    //MARK: - Properties
    let ref = Firestore.firestore()
    
    
    //MARK: - Session and Members Functions
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
    
    
    //MARK: - Route Functions
    func firestoreSaveNewRoute(forSession session: Session, route: Route) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeCollectionType).document(Session.SessionKey.routeDocumentType).setData(route.routeDictionaryRepresentation)
    }
    
    func firestoreDeleteRoute(fromSession session: Session) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeCollectionType).document(Session.SessionKey.routeDocumentType).delete()
    }
    
    func firestoreShareDirections(forSession session: Session, using route: Route) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeCollectionType).document(Session.SessionKey.routeDocumentType).updateData([Route.RouteKey.isShowingDirections : true])
    }
    
    func firestoreUpdateRouteTravelTime(forSession session: Session, withMemberID deviceID: String, withTime travelTime: Double) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(deviceID).updateData([Member.MemberKey.expectedTravelTime : travelTime])
    }
    
    func firestoreUpdateRouteToDriving(forSession session: Session, forRoute route: Route) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeCollectionType).document(Session.SessionKey.routeDocumentType).updateData([Route.RouteKey.isDriving : true])
    }
    
    func firestoreUpdateRouteToWalking(forSession session: Session, forRoute route: Route) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeCollectionType).document(Session.SessionKey.routeDocumentType).updateData([Route.RouteKey.isDriving : false])
    }

    
    //MARK: - Listeners
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
    
    func firestoreListenToRoutes(forSession session: Session, completion: @escaping(Result<[Route], FirebaseError>) -> Void) -> ListenerRegistration {
        let routesListener = ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeCollectionType).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let documentsData = querySnapshot?.documents else { completion(.failure(.noDataFound)) ; return }
            let routeDictArray      = documentsData.compactMap { $0.data() }
            let routes              = routeDictArray.compactMap { Route(fromRouteDictionary: $0) }
            completion(.success(routes))
        }
        
        return routesListener
    }
}
