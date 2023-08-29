//
//  ActiveSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import Foundation
import FirebaseFirestore

protocol ActiveSessionViewModelDelegate: AnyObject {
    func sessionDataUpdated()
    func sessionReturnedNil()
}

class ActiveSessionViewModel {
    
    //MARK: - PROPERTIES
    var session: Session
    var service: FirebaseService
    var sessionListener: ListenerRegistration?
    var memberListener: ListenerRegistration?
    var routesListener: ListenerRegistration?
    
    private weak var delegate: ActiveSessionViewModelDelegate?
    weak var mapHomeDelegate: MapHomeViewController?
    
    let sectionTitles = ["Active Members", "Waiting Room"]
    
    init(session: Session, service: FirebaseService = FirebaseService(), delegate: ActiveSessionViewModelDelegate, mapHomeDelegate: MapHomeViewController) {
        self.session         = session
        self.service         = service
        self.delegate        = delegate
        self.mapHomeDelegate = mapHomeDelegate
    }
    
    
    //MARK: - LISTENERS
    func updateSession() {
        sessionListener = service.firestoreListenToSession(forSession: session) { result in
            switch result {
            case .success(let updatedSession):
                self.session = updatedSession
                self.delegate?.sessionDataUpdated()
            case .failure(let error):
                self.delegate?.sessionReturnedNil()
                print(error.localizedDescription, "ActionSessionViewModel: Session returned nil")
            }
        }
    }
    
    func updateMembers() {
        memberListener = service.firestoreListenToMembers(forSession: session) { result in
            switch result {
            case .success(let updatedMembers):
                self.session.members = updatedMembers
                self.delegate?.sessionDataUpdated()
            case .failure(let error):
                print(error.localizedDescription, "ActionSessionViewModel: Members returned nil")
            }
        }
    }
    
    func updateRouteAnnotations() {
        routesListener = service.firestoreListenToRoutes(forSession: session) { result in
            switch result {
            case .success(let updatedRouteAnnotations):
                self.session.routeAnnotations = updatedRouteAnnotations
                self.delegate?.sessionDataUpdated()
            case .failure(let error):
                print(error.localizedDescription, "ActionSessionViewModel: RouteAnnotations returned nil")
            }
        }
    }
    
    
    //MARK: - CRUD FUNCTIONS
    func deleteSession() {
        for member in session.members {
            service.firestoreDeleteMember(fromSession: session, withMember: member)
        }
        service.firestoreDeleteRoute(fromSession: session)
        service.firestoreDeleteSession(session: session)
    }
    
    func deleteMemberFromActiveSession(fromSession session: Session, forMember member: Member) {
        service.firestoreDeleteMember(fromSession: session, withMember: member)
    }
    
    func admitNewMember(forSession session: Session, withMember member: Member) {
        service.firestoreAdmitMember(forSession: session, forMember: member)
    }
    
    func denyNewMember(forSession session: Session, withMember member: Member) {
        service.firestoreDeleteMember(fromSession: session, withMember: member)
    }
}
