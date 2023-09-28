//
//  MapViewController+ViewModelDelegate.swift
//  MapShare
//
//  Created by iMac Pro on 9/1/23.
//

import UIKit
import Ably
import MapKit
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
            mapViewModel.updateMemberCounts(forActiveLabel: membersInActiveSessionLabel,
                                                forWaitingLabel: membersInWaitingRoomLabel)
            
            // Updates the Active/Waiting Room UI
            if waitingRoomMembers.count > 0 {
                waitingRoomStackView.backgroundColor = .yellow
            } else {
                waitingRoomStackView.backgroundColor = .clear
            }
            
            // Adds a Member Annoation after a member isActive
            if session.routes.isEmpty {
                mapView.removeAnnotations(memberAnnotations)
                mapView.addAnnotations(activeMembers)
                mapViewModel.resetZoomToCenterMembers(forMapView: mapView, centerLocationButton: centerLocationButton)
            } else {
                mapView.removeAnnotations(memberAnnotations)
                mapView.addAnnotations(activeMembers)
            }
        }
    }
    
    func changesInRoute() {
        // ONE ROUTE AT A TIME: Removes Route Annotation after tapping clear button
        let routeAnnotations = mapView.annotations.filter { ($0 is Route) }
        mapView.removeAnnotations(routeAnnotations)
        // ONE ROUTE AT A TIME: Removes route directions after tapping clear button
        mapView.removeOverlays(mapView.overlays)
        
        guard let session = mapViewModel.mapShareSession else { return }
        if session.members.first(where: { Constants.Device.deviceID == $0.deviceID && $0.isActive }) != nil {
            // Displays directions for all Active Members and sets zoom to include all
            displayDirectionsWithTravelType(forSession: session)
            
            if session.routes.isEmpty {
                centerRouteButton.isHidden  = true
            } else {
                centerRouteButton.isHidden = false
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
            
            let updatedCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            UIView.animate(withDuration: 1) {
                memberToUpdate.coordinate = updatedCoordinates
            }
        }
    }
}
