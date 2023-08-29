//
//  ActiveSessionTableViewCell.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import UIKit

class ActiveSessionTableViewCell: UITableViewCell {

    //MARK: - OUTLETS
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberScreenNameLabel: UILabel!
    @IBOutlet weak var isOrganizerLabel: UILabel!
    @IBOutlet weak var transportTypeLabel: UILabel!
    @IBOutlet weak var expectedTravelTimeLabel: UILabel!
    @IBOutlet weak var dotColorLabel: UILabel!
    
    
    //MARK: - FUNCTIONS
    func configureCell(forSession session: Session, with member: Member) {
        memberNameLabel.text           = "\(member.firstName) \(member.lastName)"
        memberScreenNameLabel.text     = member.title
        isOrganizerLabel.textColor     = UIElements.Color.mapShareYellow
        dotColorLabel.textColor = String.convertToColorFromString(string: member.color)
        
        guard let timeAsDouble = member.expectedTravelTime else {  return }
        
        if timeAsDouble > 0 {
            expectedTravelTimeLabel.text = timeAsDouble.asHoursAndMinsString(style: .abbreviated)
            expectedTravelTimeLabel.isHidden = false
            transportTypeLabel.isHidden      = false
        } else if timeAsDouble == 0 {
            expectedTravelTimeLabel.text = "Arrived"
            expectedTravelTimeLabel.isHidden = false
            transportTypeLabel.isHidden      = true
        } else {
            expectedTravelTimeLabel.isHidden = true
            transportTypeLabel.isHidden      = true
        }
        
        if member.isOrganizer == false {
            isOrganizerLabel.isHidden = true
        } else {
            isOrganizerLabel.isHidden = false
        }
        
        if let routeAnnotation = session.route.first {
            if routeAnnotation.isDriving {
                transportTypeLabel.text = "Driving ETA"
            } else {
                transportTypeLabel.text = "Walking ETA"
            }
        }
    }
} //: CLASS
