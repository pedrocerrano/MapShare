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
}

class JoinSessionViewModel {
    
    //MARK: - PROPERTIES
    var locationManager = CLLocationManager()
    var validSessionCode = ""
    var searchedSession: Session?
    var service: FirebaseService
    private weak var delegate: JoinSessionViewModelDelegate?
    weak var mapHomeDelegate: MapHomeViewController?
    
    init(service: FirebaseService = FirebaseService(), delegate: JoinSessionViewModelDelegate, mapHomeDelegate: MapHomeViewController) {
        self.service         = service
        self.delegate        = delegate
        self.mapHomeDelegate = mapHomeDelegate
    }
    
    
    //MARK: - FUNCTIONS
    func searchFirebase(with code: String) {
        service.firestoreSearchForActiveSession(withCode: code) { result in
            switch result {
            case .success(let searchedSession):
                self.delegate?.sessionExists()
                self.searchedSession = searchedSession
            case .failure(let error):
                self.delegate?.noSessionFoundWithCode()
                print(error.localizedDescription, "JoinSessionViewModel: No session found")
            }
        }
    }
    
    func addNewMemberToActiveSession(withCode validCode: String, firstName: String, lastName: String, screenName: String, markerColor: String, memberLatitude: Double, memberLongitude: Double) {
        guard let memberDeviceID = Constants.Device.deviceID else { return }
        let newMemberCoordinates = CLLocationCoordinate2D(latitude: memberLatitude, longitude: memberLongitude)
        let newMember            = Member(firstName: firstName,
                                          lastName: lastName,
                                          color: markerColor,
                                          deviceID: memberDeviceID,
                                          isOrganizer: false,
                                          isActive: false,
                                          coordinate: newMemberCoordinates,
                                          title: screenName)
        
        searchedSession?.members.append(newMember)
        
        guard let searchedSession else { return }
        service.firestoreJoinNewMember(withCode: validCode, withMember: newMember) {
            self.mapHomeDelegate?.mapHomeViewModel.delegateUpdateWithSession(session: searchedSession)
        }
    }
}
