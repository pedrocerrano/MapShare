//
//  JoinSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/8/23.
//

import MapKit

protocol JoinSessionViewModelDelegate: AnyObject {
    func sessionExists()
    func noSessionFoundWithCode()
    func waitingForAdmission()
}

class JoinSessionViewModel {
    
    //MARK: - PROPERTIES
    var locationManager = CLLocationManager()
    var validSessionCode = ""
    var searchedSession: Session?
    var service: FirebaseService
    private weak var delegate: JoinSessionViewModelDelegate?
    
    init(service: FirebaseService = FirebaseService(), delegate: JoinSessionViewModelDelegate) {
        self.service     = service
        self.delegate    = delegate
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
        service.appendMemberToSessionOnFirestore(withCode: validCode, member: newMember) {
            self.delegate?.waitingForAdmission()
        }
    }
}
