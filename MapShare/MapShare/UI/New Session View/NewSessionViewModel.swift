//
//  NewSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/1/23.
//

import MapKit

class NewSessionViewModel {
    
    //MARK: - PROPERTIES
    var locationManager = CLLocationManager()
    var session: Session?
    let service: FirebaseService
    let sessionCode = String.generateRandomCode()
    weak var mapHomeDelegate: MapHomeViewController?
    let sessionCode = String.generateRandomCode()
    
    init(service: FirebaseService = FirebaseService(), mapHomeDelegate: MapHomeViewController) {
        self.service         = service
        self.mapHomeDelegate = mapHomeDelegate
    }
    
    
    //MARK: - FUNCTIONS
    func createNewMapShareSession(sessionName: String, sessionCode: String, firstName: String, lastName: String, screenName: String, markerColor: String, organizerLatitude: Double, organizerLongitude: Double) {
        guard let organizerDeviceID = Constants.Device.deviceID else { return }
        let organizer               = Member(firstName: firstName,
                                             lastName: lastName,
                                             screenName: screenName,
                                             mapMarkerColor: markerColor,
                                             memberDeviceID: organizerDeviceID,
                                             isOrganizer: true,
                                             isActive: true,
                                             currentLocLatitude: organizerLatitude,
                                             currentLocLongitude: organizerLongitude)
        
        let organizerCoordinates = CLLocationCoordinate2D(latitude: organizerLatitude, longitude: organizerLongitude)
        let organizerAnnotation = MemberAnnotation(deviceID: organizerDeviceID,
                                                   coordinate: organizerCoordinates,
                                                   title: screenName,
                                                   color: markerColor,
                                                   isShowing: true)
        
        let newSession  = Session(sessionName: sessionName,
                                  sessionCode: sessionCode,
                                  organizerDeviceID: organizerDeviceID,
                                  members: [organizer],
                                  routeAnnotations: [],
                                  memberAnnotations: [organizerAnnotation],
                                  isActive: true)
        
        session = newSession
        service.saveNewSessionToFirestore(newSession: newSession, withMember: organizer, withMemberAnnotation: organizerAnnotation) {
            self.mapHomeDelegate?.delegateUpdateWithSession(session: newSession)
        }
    }
}
