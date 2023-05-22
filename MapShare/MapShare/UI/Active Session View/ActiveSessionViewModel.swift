//
//  ActiveSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import Foundation

protocol ActiveSessionViewModelDelegate: AnyObject {
    func sessionDataUpdated()
    func memberDataUpdated()
    func sessionReturnedNil()
}

class ActiveSessionViewModel {
    
    //MARK: - PROPERTIES
    var session: Session
    var service: FirebaseService
    let sectionTitles = ["Active Members", "Waiting Room"]
    private weak var delegate: ActiveSessionViewModelDelegate?
    weak var mapHomeDelegate: MapHomeViewController?
    
    init(session: Session, service: FirebaseService = FirebaseService(), delegate: ActiveSessionViewModelDelegate, mapHomeDelegate: MapHomeViewController) {
        self.session         = session
        self.service         = service
        self.delegate        = delegate
        self.mapHomeDelegate = mapHomeDelegate
    }
    
    //MARK: - FUNCTIONS
    func updateSession() {
        service.listenForChangesToSession(forSession: session.sessionCode) { result in
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
        self.service.listenForChangesToMembers(forSession: session) { result in
            switch result {
            case .success(let updatedMembers):
                self.session.members = updatedMembers
                self.delegate?.memberDataUpdated()
            case .failure(let error):
                print(error.localizedDescription, "ActionSessionViewModel: Members returned nil")
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
    }
}
