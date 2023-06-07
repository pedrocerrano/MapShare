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
    var memberAnnotationsListener: ListenerRegistration?
    
    let sectionTitles = ["Active Members", "Waiting Room"]
    private weak var delegate: ActiveSessionViewModelDelegate?
    weak var mapHomeDelegate: MapHomeViewController?
    
    init(session: Session, service: FirebaseService = FirebaseService(), delegate: ActiveSessionViewModelDelegate, mapHomeDelegate: MapHomeViewController) {
        self.session         = session
        self.service         = service
        self.delegate        = delegate
        self.mapHomeDelegate = mapHomeDelegate
    }
    
    
    //MARK: - LISTENERS
    func updateSession() {
        sessionListener = service.listenForChangesToSession(forSession: session) { result in
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
        memberListener = service.listenForChangesToMembers(forSession: session) { result in
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
        routesListener = service.listenToChangesForRoutes(forSession: session) { result in
            switch result {
            case .success(let updatedRouteAnnotations):
                self.session.routeAnnotations = updatedRouteAnnotations
                self.delegate?.sessionDataUpdated()
            case .failure(let error):
                print(error.localizedDescription, "ActionSessionViewModel: RouteAnnotations returned nil")
            }
        }
    }
    
    func updateMemberAnnotations() {
        memberAnnotationsListener = service.listenToChangesToMemberAnnotations(forSession: session) { result in
            switch result {
            case .success(let updatedMemberAnnotations):
                self.session.memberAnnotations = updatedMemberAnnotations
                self.delegate?.sessionDataUpdated()
            case .failure(let error):
                print(error.localizedDescription, "ActionSessionViewModel: MemberAnnotations returned nil")
            }
        }
    }
    
    
    //MARK: - CRUD FUNCTIONS
    func deleteSession() {
        for member in session.members {
            service.deleteMemberFromFirestore(fromSession: session, withMember: member)
        }
        service.deleteRouteOnFirestore(fromSession: session)
        service.deleteSessionFromFirestore(session: session)
    }
    
    func deleteMemberFromActiveSession(fromSession session: Session, forMember member: Member) {
        service.deleteMemberFromFirestore(fromSession: session, withMember: member)
    }
    
    func admitNewMember(forSession session: Session, withMember member: Member, withMemberAnnotation memberAnnotation: MemberAnnotation) {
        service.admitMemberToActiveSessionOnFirestore(forSession: session, forMember: member, withMemberAnnotation: memberAnnotation)
    }
    
    func denyNewMember(forSession session: Session, withMember member: Member) {
        service.deleteMemberFromFirestore(fromSession: session, withMember: member)
    }
}
