//
//  MemberAnnotation.swift
//  MapShare
//
//  Created by Chase on 5/11/23.
//

import MapKit
import CoreLocation

class MemberAnnotation: NSObject, MKAnnotation {
    
    enum MemberAnnotationKey {
        static let deviceID            = "deviceID"
        static let memberAnnoLatitude  = "memberAnnoLatitude"
        static let memberAnnoLongitude = "memberAnnoLongitude"
        static let title               = "title"
        static let color               = "color"
        static let isShowing           = "isShowing"
    }
    
    var deviceID: String
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var color: String
    var isShowing: Bool
    
    var memberAnnotationDictionaryRepresentation: [String : AnyHashable] {
        [
            MemberAnnotationKey.deviceID            : self.deviceID,
            MemberAnnotationKey.memberAnnoLatitude  : self.coordinate.latitude,
            MemberAnnotationKey.memberAnnoLongitude : self.coordinate.longitude,
            MemberAnnotationKey.title               : self.title,
            MemberAnnotationKey.color               : self.color,
            MemberAnnotationKey.isShowing           : self.isShowing
        ]
    }
    
    init(deviceID: String, coordinate: CLLocationCoordinate2D, title: String?, color: String, isShowing: Bool) {
        self.deviceID   = deviceID
        self.coordinate = coordinate
        self.title      = title
        self.color      = color
        self.isShowing  = isShowing
    }
}



//MARK: - EXT: Convenience Initializer
extension MemberAnnotation {
    convenience init?(fromMemberAnnotationDictionary memberAnnotationDictionary: [String : Any]) {
        guard let deviceID  = memberAnnotationDictionary[MemberAnnotationKey.deviceID] as? String,
              let memberAnnoLatitude  = memberAnnotationDictionary[MemberAnnotationKey.memberAnnoLatitude] as? Double,
              let memberAnnoLongitude = memberAnnotationDictionary[MemberAnnotationKey.memberAnnoLongitude] as? Double,
              let title               = memberAnnotationDictionary[MemberAnnotationKey.title] as? String,
              let color               = memberAnnotationDictionary[MemberAnnotationKey.color] as? String,
        let isShowing           = memberAnnotationDictionary[MemberAnnotationKey.isShowing] as? Bool  else {
            print("Failed to initialize MemberAnnotation model object")
            return nil
        }
        
        self.init(deviceID: deviceID, coordinate: CLLocationCoordinate2D(latitude: memberAnnoLatitude, longitude: memberAnnoLongitude), title: title, color: color, isShowing: isShowing)
    }
}
