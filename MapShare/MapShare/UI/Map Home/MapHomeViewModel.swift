//
//  MapHomeViewModel.swift
//  MapShare
//
//  Created by Chase on 5/16/23.
//

import UIKit
import MapKit
import FirebaseFirestore

protocol MapHomeViewModelDelegate: AnyObject {
    func changesInMembers()
    func changesInRoute()
    func noSessionActive()
}

class MapHomeViewModel {
    
    //MARK: - Properties
    var service: FirebaseService
    var sessionListener: ListenerRegistration?
    var memberListener: ListenerRegistration?
    var deletedMemberListener: ListenerRegistration?
    var routesListener: ListenerRegistration?
    
    var mapShareSession: Session?
    var memberAnnotationToDelete: Member?
    private weak var delegate: MapHomeViewModelDelegate?
    
    var directionsArray: [MKDirections] = []
    let locationManager = CLLocationManager()
    var isDriving       = true
    var zoomAllRoutes   = true
    var zoomAllMembers  = true
    
    let routeDirectionsButton = UIButton(type: .detailDisclosure)
    
    init(service: FirebaseService = FirebaseService(), delegate: MapHomeViewModelDelegate) {
        self.service  = service
        self.delegate = delegate
    }
    
    
    //MARK: - Firebase Listeners
    func updateSessionChanges() {
        guard let mapShareSession else { return }
        sessionListener = service.firestoreListenToSession(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedSession):
                mapShareSession.sessionCode       = loadedSession.sessionCode
                mapShareSession.sessionName       = loadedSession.sessionName
                mapShareSession.organizerDeviceID = loadedSession.organizerDeviceID
            case .failure(let error):
                self.delegate?.noSessionActive()
                print(error.localizedDescription, "MapHomeViewModel: Issue with the Session data")
            }
        }
    }
    
    func updateMemberChanges() {
        guard let mapShareSession else { return }
        memberListener = service.firestoreListenToMembers(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedMembers):
                mapShareSession.members = loadedMembers
                self.delegate?.changesInMembers()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: Issue with the Members data")
            }
        }
    }
    
    func updateRouteChanges() {
        guard let mapShareSession else { return }
        routesListener = service.firestoreListenToRoutes(forSession: mapShareSession) { result in
            switch result {
            case .success(let loadedRoute):
                mapShareSession.routes = loadedRoute
                self.delegate?.changesInRoute()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: Issue with the Routes data")
            }
        }
    }
    
    func updateAnnotationsForDeletedMember() {
        guard let mapShareSession else { return }
        deletedMemberListener = service.firestoreListenForDeletedMembers(forSession: mapShareSession) { result in
            switch result {
            case .success(let deletedMembers):
                mapShareSession.deletedMembers = deletedMembers
                if !mapShareSession.routes.isEmpty {
                    self.delegate?.changesInRoute()
                }
                self.delegate?.changesInMembers()
            case .failure(let error):
                print(error.localizedDescription, "MapHomeViewModel: Issue with the DeletedMembers")
            }
        }
    }
    
    
    //MARK: - Firebase CRUD Functions
    func saveRouteToFirestore(newRoute: Route) {
        guard let mapShareSession else { return }
        service.firestoreSaveNewRoute(forSession: mapShareSession, route: newRoute)
    }
    
    func deleteRouteFromFirestore() {
        guard let mapShareSession else { return }
        service.firestoreDeleteRoute(fromSession: mapShareSession)
    }
    
    func updateMemberTravelTime(withMemberID deviceID: String, withTravelTime travelTime: Double) {
        guard let mapShareSession else { return }
        service.firestoreUpdateRouteTravelTime(forSession: mapShareSession, withMemberID: deviceID, withTime: travelTime)
    }
    
    func updateToDriving() {
        guard let mapShareSession,
              let route = mapShareSession.routes.first
        else { return }
        
        service.firestoreUpdateRouteToDriving(forSession: mapShareSession, forRoute: route)
    }
    
    func updateToWalking() {
        guard let mapShareSession,
              let route = mapShareSession.routes.first
        else { return }
        
        service.firestoreUpdateRouteToWalking(forSession: mapShareSession, forRoute: route)
    }
    
    func clearFirebaseDeletedMemberAfterRemovingAnnotation(for deletedMember: DeletedMember) {
        guard let mapShareSession else { return }
        service.firestoreClearDeletedMembers(fromSession: mapShareSession, forDeletedMember: deletedMember)
    }
    
    func updateMemberLocation(forMember member: Member, withLatitude: Double, withLongitude: Double) {
        // This is the function to update Real-Time Location update with Ably
    }
    
    
    //MARK: - Other Functions
    func delegateUpdateWithSession(session: Session) {
        mapShareSession = session
        updateSessionChanges()
        updateMemberChanges()
        updateRouteChanges()
        updateAnnotationsForDeletedMember()
        shareDirections()
    }
    
    func updateMemberCounts(forActiveLabel membersInActiveSessionLabel: UILabel, forWaitingLabel membersInWaitingRoomLabel: UILabel) {
        guard let members                = mapShareSession?.members else { return }
        let activeMembers                = members.filter { $0.isActive }.count
        let waitingRoomMembers           = members.filter { !$0.isActive }.count
        membersInActiveSessionLabel.text = "\(activeMembers)"
        membersInWaitingRoomLabel.text   = "\(waitingRoomMembers)"
    }
}
