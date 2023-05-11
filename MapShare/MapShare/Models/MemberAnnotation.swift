//
//  MemberAnnotation.swift
//  MapShare
//
//  Created by Chase on 5/11/23.
//

import MapKit
import CoreLocation

class MemberAnnotation: NSObject, MKAnnotation {
    
    var member: Member
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var annotationColor: String
    
    init(member: Member, coordinate: CLLocationCoordinate2D, title: String?, annotationColor: String) {
        self.member = member
        self.coordinate = coordinate
        self.title = title
        self.annotationColor = annotationColor
    }
}
