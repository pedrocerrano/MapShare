//
//  JoinSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/8/23.
//

import Foundation

protocol JoinSessionViewModelDelegate: AnyObject {
    func sessionExists()
    func noSessionFoundWithCode()
}

class JoinSessionViewModel {
    
    //MARK: - PROPERTIES
    var validSessionCode = ""
    var member: Member?
    var service: FirebaseService
    private weak var delegate: JoinSessionViewModelDelegate?
    
    init(member: Member? = nil, service: FirebaseService = FirebaseService(), delegate: JoinSessionViewModelDelegate) {
        self.member   = member
        self.service  = service
        self.delegate = delegate
    }
    
    
    //MARK: - FUNCTIONS
    func searchFirebase(with code: String) {
        service.searchFirebaseForActiveSession(withCode: code) { result in
            switch result {
            case .success(let bool):
                if bool == true {
                    self.delegate?.sessionExists()
                } else {
                    self.delegate?.noSessionFoundWithCode()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func addNewMemberToActiveSession(withCode validCode: String, firstName: String, lastName: String, screenName: String, markerColor: String, memberLatitude: Double, memberLongitude: Double) {
        let newMemberUUID = UUID().uuidString
        let newMember     = Member(firstName: firstName,
                                   lastName: lastName,
                                   screenName: screenName,
                                   mapMarkerColor: markerColor,
                                   memberUUID: newMemberUUID,
                                   isOrganizer: false,
                                   isActive: false,
                                   currentLocLatitude: memberLatitude,
                                   currentLocLongitude: memberLongitude)
        member = newMember
        service.addMemberToSessionOnFirestore(withCode: validCode, member: newMember) {
            #warning("Work on the waiting room Activity Indicator")
        }
    }
}
