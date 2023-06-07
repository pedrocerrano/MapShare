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
    func saveNewSessionToFirestore(newSession session: Session, withMember member: Member, withMemberAnnotation memberAnnotation: MemberAnnotation, completion: @escaping () -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).setData(session.sessionDictionaryRepresentation)
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).setData(member.memberDictionaryRepresentation)
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.memberAnnotationCollectionType).document(memberAnnotation.deviceID).setData(memberAnnotation.memberAnnotationDictionaryRepresentation)
        completion()
    }
    
    func searchForActiveSessionOnFirestore(withCode codeEntered: String, completion: @escaping(Result<Session, FirebaseError>) -> Void) {
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
    
    func joinNewMemberToActiveSessionOnFirestore(withCode sessionCode: String, withMember member: Member, withMemberAnnotation memberAnnotation: MemberAnnotation, completion: @escaping() -> Void) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).setData(member.memberDictionaryRepresentation)
        ref.collection(Session.SessionKey.sessionCollectionType).document(sessionCode).collection(Session.SessionKey.memberAnnotationCollectionType).document(memberAnnotation.deviceID).setData(memberAnnotation.memberAnnotationDictionaryRepresentation)
        completion()
    }
    
    func admitMemberToActiveSessionOnFirestore(forSession session: Session, forMember member: Member, withMemberAnnotation memberAnnotation: MemberAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).updateData([Member.MemberKey.isActive : true])
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.memberAnnotationCollectionType).document(member.memberDeviceID).updateData([MemberAnnotation.MemberAnnotationKey.isShowing : true])
    }
    
    func updateLocationOfMemberAnnotationToFirestore(forSession session: Session, forAnnotation memberAnnotation: MemberAnnotation, withLatitude: Double, withLongitude: Double) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.memberAnnotationCollectionType).document(memberAnnotation.deviceID).updateData([MemberAnnotation.MemberAnnotationKey.memberAnnoLatitude : withLatitude, MemberAnnotation.MemberAnnotationKey.memberAnnoLongitude : withLongitude])
    }
    
    func deleteSessionFromFirestore(session: Session) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).delete()
    }
    
    func deleteMemberFromFirestore(fromSession session: Session, withMember member: Member) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(member.memberDeviceID).delete()
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.memberAnnotationCollectionType).document(member.memberDeviceID).delete()
    }
    
    
    //MARK: - ROUTE ANNOTATIONS CRUD FUNCTIONS
    func saveNewRouteToFirestore(forSession session: Session, routeAnnotation: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).setData(routeAnnotation.routeAnnotationDictionaryRepresentation)
    }
    
    func deleteRouteOnFirestore(fromSession session: Session) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).delete()
    }
    
    func showDirectionsToMembers(forSession session: Session, using routeAnnotation: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).updateData([RouteAnnotation.RouteAnnotationKey.isShowingDirections : true])
    }
    
    func updateExpectedTravelTime(forSession session: Session, withMemberID deviceID: String, withTime travelTime: Double) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.membersCollectionType).document(deviceID).updateData([Member.MemberKey.expectedTravelTime : travelTime])
    }
    
    func updateTransportTypeToDriving(forSession session: Session, forRoute route: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).updateData([RouteAnnotation.RouteAnnotationKey.isDriving : true])
    }
    
    func updateTransportTypeToWalking(forSession session: Session, forRoute route: RouteAnnotation) {
        ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.routeAnnotationCollectionType).document(Session.SessionKey.routeDocumentType).updateData([RouteAnnotation.RouteAnnotationKey.isDriving : false])
    }

    
    //MARK: - LISTENERS
    func listenForChangesToSession(forSession session: Session, completion: @escaping(Result<Session, FirebaseError>) -> Void) -> ListenerRegistration {
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
    
    func listenForChangesToMembers(forSession session: Session, completion: @escaping(Result<[Member], FirebaseError>) -> Void) -> ListenerRegistration {
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
    
    func listenToChangesForRoutes(forSession session: Session, completion: @escaping(Result<[RouteAnnotation], FirebaseError>) -> Void) -> ListenerRegistration {
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
    
    func listenToChangesToMemberAnnotations(forSession session: Session, completion: @escaping(Result<[MemberAnnotation], FirebaseError>) -> Void) -> ListenerRegistration {
        let memberAnnotationsListener = ref.collection(Session.SessionKey.sessionCollectionType).document(session.sessionCode).collection(Session.SessionKey.memberAnnotationCollectionType).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
            
            guard let documentsData = querySnapshot?.documents else { completion(.failure(.noDataFound)) ; return }
            let memberAnnoDictArray = documentsData.compactMap { $0.data() }
            let memberAnnotations   = memberAnnoDictArray.compactMap { MemberAnnotation(fromMemberAnnotationDictionary: $0) }
            completion(.success(memberAnnotations))
        }
        
        return memberAnnotationsListener
    }
}
