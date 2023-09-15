//
//  MapViewController+ViewModelDelegate.swift
//  MapShare
//
//  Created by iMac Pro on 9/1/23.
//

import UIKit
import Ably
import CoreLocation

extension MapViewController: MapViewModelDelegate {
    
    func changesInMembers() {
        guard let session      = mapViewModel.mapShareSession else { return }
        let waitingRoomMembers = session.members.filter { !$0.isActive }
        let activeMembers      = session.members.filter { $0.isActive }
        let memberAnnotations  = mapView.annotations.filter { ($0 is Member) }
        
        if session.members.first(where: { Constants.Device.deviceID == $0.deviceID && $0.isActive }) != nil {
            // Configures the Session Info at the top
            sessionActivityIndicatorLabel.textColor = UIColor.mapShareGreen()
            activeMembersStackView.isHidden = false
            waitingRoomStackView.isHidden   = false
            refreshLocationButton.isHidden  = false
            mapViewModel.updateMemberCounts(forActiveLabel: membersInActiveSessionLabel,
                                                forWaitingLabel: membersInWaitingRoomLabel)
            
            // Updates the Active/Waiting Room UI
            if waitingRoomMembers.count > 0 {
                waitingRoomStackView.backgroundColor = .yellow
            } else {
                waitingRoomStackView.backgroundColor = .clear
            }
            
            // Adds a Member as an annoation after a member isActive
            if memberAnnotations.isEmpty {
                mapView.addAnnotations(activeMembers)
                                        print("[MEMBER ANNO] 1 - Not empty anymore!")
                                        print("[MEMBER ANNO] 1 - ADDED: \(activeMembers.first!.title!)")
            } else {
                for activeMember in activeMembers {
                    let memberAnnotationTitles = memberAnnotations.map { $0.title ?? "" }
                                        print("[MEMBER ANNO] 2 - Titles: \(memberAnnotationTitles)")
                    let memberExists = memberAnnotationTitles.contains(activeMember.title)
                    if memberExists {
                                        print("[MEMBER ANNO] 3 - EXISTS: \(activeMember.title ?? "")")
                                        print("[MEMBER ANNO] 3 - All Titles: \(memberAnnotations.map({ $0.title ?? "" } ))")
                                        print("[MEMBER ANNO] 3 - All Titles count: \(memberAnnotations.count)")
                    } else {
                        mapView.addAnnotation(activeMember)
                        
                        // Sets zoom for when there is more than one members
                        mapViewModel.resetZoomForAllMembers(mapView: mapView)
                                        print("[MEMBER ANNO] 4 - ADDED: \(activeMember.title ?? "")")
                                        print("[MEMBER ANNO] 4 - All Titles: \(memberAnnotations.map({ $0.title ?? "" } ))")
                                        print("[MEMBER ANNO] 4 - All Titles count: \(memberAnnotations.count)")
                    }
                }
            }
            
            mapViewModel.addOne()
                                        print("[RUN CODE]: \(mapViewModel.runCode)")
            
            
            // Removes MemberAnnotation from remaining active devices after another Member exits the Session
            guard let deletedMember = session.deletedMembers.first else { print("deletedMember failed") ; return }
                                        print("[DELETE MEMBER] 1 - Made it here")
            if let memberAnnotationToDelete = memberAnnotations.first(where: { $0.title == deletedMember.title }) {
                                        print("[DELETE MEMBER] 2 - DeletedMemeber: \(deletedMember.title)")
                                        print("[DELETE MEMBER] 3 - MemberAnnotationToDelete: \(String(describing: memberAnnotationToDelete.title ?? ""))")
                mapView.removeAnnotation(memberAnnotationToDelete)
                                        print("[DELETE MEMBER] 4 - MemberAnnotationToDelete REMOVED: \(String(describing: memberAnnotationToDelete.title ?? ""))")
                mapViewModel.clearFirebaseDeletedMemberAfterRemovingAnnotation(for: deletedMember)
                mapViewModel.mapShareSession?.deletedMembers = []
                mapViewModel.resetZoomForAllMembers(mapView: mapView)
                                        print("[DELETE MEMBER] 5 - MemberAnnotations: \(memberAnnotations.map({ $0.title ?? "" } ))")
                                        print("[DELETE MEMBER] 6 - MemberAnnotations Count: \(memberAnnotations.count)")
            }
        }
    }
    
    func changesInRoute() {
        // Ensures only one route available at a time
        let routeAnnotations = mapView.annotations.filter { ($0 is Route) }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        
        guard let session = mapViewModel.mapShareSession,
              let route   = session.routes.first
        else { return }
        
        if session.members.first(where: { Constants.Device.deviceID == $0.deviceID && $0.isActive }) != nil {
            if route.isDriving {
                displayDirections(forSession: session, withTravelType: .automobile)
            } else {
                displayDirections(forSession: session, withTravelType: .walking)
            }
            
            if !session.routes.isEmpty {
                centerRouteButton.isHidden = false
            } else {
                centerRouteButton.isHidden  = true
            }
        }
    }
    
    func noSessionActive() {
        // Remove ALL annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Hides buttons
        hideButtons(true)
        
        // Resets the View Model Session data
        mapViewModel.mapShareSession = nil
        mapViewModel.updateMemberCounts(forActiveLabel: membersInActiveSessionLabel,
                                            forWaitingLabel: membersInWaitingRoomLabel)
        
        // Resets mapView
        sessionActivityIndicatorLabel.textColor = .systemGray
        mapViewModel.isDriving     = true
        mapViewModel.zoomAllRoutes = true
        mapView.showsUserLocation  = true
        mapViewModel.resetZoomForSingleMember(mapView: mapView)
        
        // Removes Firestore Listeners
        mapViewModel.sessionListener?.remove()
        mapViewModel.memberListener?.remove()
        mapViewModel.routesListener?.remove()
        mapViewModel.deletedMemberListener?.remove()
    }
    
    func ablyMessagesUpdate(message: ARTMessage) {
        guard let memberToUpdate = mapViewModel.mapShareSession?.members.first(where: { $0.title == message.name }) else { return }
        if memberToUpdate.title == message.name {
            let receivedCoordinateString = "\(message.data ?? "ZYX")"
            let coordinates              = receivedCoordinateString.components(separatedBy: ":")
            guard let latitudeString  = coordinates.first,
                  let longitudeString = coordinates.last,
                  let latitude        = Double(latitudeString),
                  let longitude       = Double(longitudeString)
            else { return }
            
            ablyMessagesLabel.text = "\(memberToUpdate.title ?? "AAA")\nLat: \(latitude)\nLon: \(longitude)"
            let updatedCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            UIView.animate(withDuration: 0.5) {
                memberToUpdate.coordinate = updatedCoordinates
            }
        }
    }
}
