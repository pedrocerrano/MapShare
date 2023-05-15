//
//  ActiveSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import Foundation

protocol ActiveSessionViewModelDelegate: AnyObject {
    func sessionLoadedSuccessfully()
    func sessionDataUpdated()
}

class ActiveSessionViewModel {
    
    //MARK: - PROPERTIES
    var session: Session
    var service: FirebaseService
    let sectionTitles = ["Active Members", "Waiting Room"]
    private weak var delegate: ActiveSessionViewModelDelegate?
    
    init(session: Session, service: FirebaseService = FirebaseService(), delegate: ActiveSessionViewModelDelegate) {
        self.session  = session
        self.service  = service
        self.delegate = delegate
    }
    
    //MARK: - FUNCTIONS
    func loadSession() {
        service.loadSessionFromFirestore(forSession: session) { result in
            switch result {
            case .success(let loadedSession):
                self.session = loadedSession
                self.delegate?.sessionLoadedSuccessfully()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateSession() {
        service.listenForChangesToSession(forSession: session.sessionCode, forMembers: session.members) { result in
            switch result {
            case .success(let updatedSessionData):
                self.session = updatedSessionData
                self.delegate?.sessionDataUpdated()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteSession() {
        service.deleteSessionFromFirestore(session: session)
        for member in session.members {
            service.deleteAllMembersFromFirestore(session: session, member: member)
        }
    }
    
    func deleteMemberFromActiveSession(fromSession session: Session, forMember member: Member) {
        service.deleteMemberFromFirestore(fromSession: session, member: member)
    }
    
    func admitNewMember(forSession session: Session, withMember member: Member) {
        service.admitMemberToActiveSessionOnFirestore(forSession: session, forMember: member)
    }
    
    func denyNewMember(forSession session: Session, withMember member: Member) {
        service.deleteMemberFromFirestore(fromSession: session, member: member)
        print("Deleted")
    }
}
