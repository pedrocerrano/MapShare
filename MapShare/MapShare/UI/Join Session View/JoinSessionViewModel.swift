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
    var searchedSession: Session?
    var service: FirebaseService
    private weak var delegate: JoinSessionViewModelDelegate?
    weak var joinSessionDelegate: MapHomeViewController?
    
    init(service: FirebaseService = FirebaseService(), delegate: JoinSessionViewModelDelegate, joinSessionDelegate: MapHomeViewController) {
        self.service             = service
        self.delegate            = delegate
        self.joinSessionDelegate = joinSessionDelegate
    }
    
    
    //MARK: - FUNCTIONS
    func searchFirebase(with code: String) {
        service.searchFirebaseForActiveSession(withCode: code) { result in
            switch result {
            case .success(let searchedSession):
                self.delegate?.sessionExists()
                self.searchedSession = searchedSession
            case .failure(let error):
                self.delegate?.noSessionFoundWithCode()
                #warning("Need to troubleshoot noSessionFoundWithCode")
                print(error.localizedDescription)
            }
        }
    }
    
    func addNewMemberToActiveSession(withCode validCode: String, firstName: String, lastName: String, screenName: String, markerColor: String, memberLatitude: Double, memberLongitude: Double) {
        guard let memberDeviceID = Constants.Device.deviceID else { return }
        let newMember            = Member(firstName: firstName,
                                          lastName: lastName,
                                          screenName: screenName,
                                          mapMarkerColor: markerColor,
                                          memberDeviceID: memberDeviceID,
                                          isOrganizer: false,
                                          isActive: false,
                                          currentLocLatitude: memberLatitude,
                                          currentLocLongitude: memberLongitude)
        searchedSession?.members.append(newMember)
        guard let searchedSession else { return }
        service.appendMemberToSessionOnFirestore(withCode: validCode, member: newMember) {
            self.joinSessionDelegate?.updateWithSession(session: searchedSession)
        }
    }
}
