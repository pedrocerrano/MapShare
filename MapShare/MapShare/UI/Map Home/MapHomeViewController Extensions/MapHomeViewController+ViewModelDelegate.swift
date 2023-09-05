//
//  MapHomeViewController+ViewModelDelegate.swift
//  MapShare
//
//  Created by iMac Pro on 9/1/23.
//

import Foundation

extension MapHomeViewController: MapHomeViewModelDelegate {
    
    func changesInMembers() {
        guard let session = mapHomeViewModel.mapShareSession else { return }
        
        if session.members.first(where: { Constants.Device.deviceID == $0.deviceID && $0.isActive }) != nil {
            sessionActivityIndicatorLabel.textColor = UIElements.Color.mapShareGreen
            activeMembersStackView.isHidden         = false
            waitingRoomStackView.isHidden           = false
            refreshingLocationButton.isHidden       = false
            mapHomeViewModel.updateMemberCounts(forActiveLabel: membersInActiveSessionLabel, forWaitingLabel: membersInWaitingRoomLabel)
            
            // Updates the Active/Waiting Room members counts
            let waitingRoomMembers = session.members.filter { !$0.isActive }
            if waitingRoomMembers.count > 0 {
                waitingRoomStackView.backgroundColor = .yellow
            } else {
                waitingRoomStackView.backgroundColor = .clear
            }
            
            // Adds a MemberAnnoation after a member is admitted to the active session
            let activeMembers = session.members.filter { $0.isActive }
            mapView.addAnnotations(activeMembers)
            if activeMembers.count > 1 {
                mapView.showAnnotations(activeMembers, animated: true)
            }
        }
        
        // Removes MemberAnnotation from remaining active devices after another Member exits the Session
        let memberAnnotations = mapView.annotations.filter { ($0 is Member) }
        if let deletedMember = session.deletedMembers.first,
           let memberAnnotationToDelete = memberAnnotations.first(where: { $0.title == deletedMember.title }) {
//            print("DeletedMemeber:           \(deletedMember.title)")
//            print("MemberAnnotationToDelete: \(memberAnnotationToDelete.title)")
            mapView.removeAnnotation(memberAnnotationToDelete)
            mapHomeViewModel.clearFirebaseDeletedMemberAfterRemovingAnnotation(for: deletedMember)
            mapHomeViewModel.mapShareSession?.deletedMembers = []
            mapView.showAnnotations(memberAnnotations, animated: true)
        }
    }
    
    func changesInRoute() {
        // Ensures only one route available at a time
        let routeAnnotations = mapView.annotations.filter { !($0 is Member) }
        mapView.removeAnnotations(routeAnnotations)
        mapView.removeOverlays(mapView.overlays)
        
        guard let session = mapHomeViewModel.mapShareSession,
              let route   = session.routes.first
        else { return }
        
        if session.members.first(where: { Constants.Device.deviceID == $0.deviceID && $0.isActive }) != nil {
            if route.isDriving {
                displayDirections(forSession: session, withTravelType: .automobile)
            } else {
                displayDirections(forSession: session, withTravelType: .walking)
            }
            
//            if !session.route.isEmpty && session.route.first(where: { $0.isShowingDirections }) != nil {
            if !session.routes.isEmpty {
                centerRouteButton.isHidden = false
            } else {
                centerRouteButton.isHidden  = true
            }
        }
    }
    
    func noSessionActive() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        activeMembersStackView.isHidden                     = true
        waitingRoomStackView.isHidden                       = true
        travelMethodButton.isHidden                         = true
        centerRouteButton.isHidden                          = true
        refreshingLocationButton.isHidden                   = true
        mapHomeViewModel.mapShareSession?.members           = []
        mapHomeViewModel.mapShareSession?.deletedMembers    = []
        mapHomeViewModel.updateMemberCounts(forActiveLabel: membersInActiveSessionLabel, forWaitingLabel: membersInWaitingRoomLabel)
        mapHomeViewModel.mapShareSession                    = nil
        mapView.showsUserLocation                           = true
        sessionActivityIndicatorLabel.textColor             = .systemGray
        mapHomeViewModel.isDriving                          = true
        mapHomeViewModel.zoomAllRoutes                      = true
        mapHomeViewModel.resetZoomForSingleMember(mapView: mapView)
        mapHomeViewModel.sessionListener?.remove()
        mapHomeViewModel.memberListener?.remove()
        mapHomeViewModel.routesListener?.remove()
        mapHomeViewModel.deletedMemberListener?.remove()
    }
}
