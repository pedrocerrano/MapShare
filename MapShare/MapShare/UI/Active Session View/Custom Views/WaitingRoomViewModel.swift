//
//  WaitingRoomViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/12/23.
//

import Foundation

struct WaitingRoomViewModel {
    
    //MARK: - PROPERTIES
    var service: FirebaseService
    
    init(service: FirebaseService = FirebaseService()) {
        self.service = service
    }
    
    
    //MARK: - FUNCTIONS
    func admitNewMember(forSession session: Session, withMember member: Member) {
        service.admitMemberToActiveSessionOnFirestore(forSession: session, forMember: member)
    }
    
    func denyNewMember(forSession session: Session, withMember member: Member) {
        service.deleteMemberFromFirestore(fromSession: session, member: member)
    }
}
