//
//  MapHomeViewModel.swift
//  MapShare
//
//  Created by Chase on 5/16/23.
//

import Foundation
import CoreLocation

protocol MapHomeViewModelDelegate: AnyObject {
    func changesInSession()
    func changesInMembers()
}

class MapHomeViewModel {
    
    //MARK: - PROPERTIES
    var session: Session?
    var service: FirebaseService
    var memberAnnotation: MemberAnnotation?
    var memberAnnotations: [MemberAnnotation]
    private weak var delegate: MapHomeViewModelDelegate?
    
    init(service: FirebaseService = FirebaseService(), memberAnnotation: MemberAnnotation? = nil, memberAnnotations: [MemberAnnotation] = [], delegate: MapHomeViewModelDelegate) {
        self.service           = service
        self.memberAnnotation  = memberAnnotation
        self.memberAnnotations = memberAnnotations
        self.delegate          = delegate
    }
    
    //MARK: - FUNCTIONS
    func listenForSessionChanges() {
        guard let session else { return }
        service.listenForChangesToSession(forSession: session.sessionCode) { result in
            switch result {
            case .success(let loadedSession):
                self.session = loadedSession
                self.delegate?.changesInSession()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func listenForMemberChanges() {
        guard let session else { return }
        service.listenForChangesToMembers(forSession: session) { result in
            switch result {
            case .success(let members):
                session.members = members
                let filteredMembers = members.filter { $0.isActive == true }
                for member in filteredMembers {
                    let memberLocation = MemberAnnotation(member: member,
                                                          coordinate: CLLocationCoordinate2D(latitude: member.currentLocLatitude, longitude: member.currentLocLongitude),
                                                          title: member.screenName,
                                                          annotationColor: .blue)
                    self.memberAnnotations.append(memberLocation)
                }
                self.delegate?.changesInMembers()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
