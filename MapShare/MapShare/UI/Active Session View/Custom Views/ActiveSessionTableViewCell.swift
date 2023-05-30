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
    @IBOutlet weak var expectedTravelTimeLabel: UILabel!
    @IBOutlet weak var dotColorLabel: UILabel!
    
    
    //MARK: - FUNCTIONS
    func configureCell(with member: Member) {
        memberNameLabel.text           = "\(member.firstName) \(member.lastName)"
        memberScreenNameLabel.text     = member.screenName
        isOrganizerLabel.textColor     = UIElements.Color.mapShareYellow
        guard let timeAsDouble = member.expectedTravelTime else { print("ActiveMemberTableViewCell unwrapping failure") ; return }
        if timeAsDouble > 0 {
            expectedTravelTimeLabel.text = "ETA " + timeAsDouble.asHoursAndMinsString(style: .abbreviated)
            expectedTravelTimeLabel.isHidden = false
        } else if timeAsDouble == 0 {
            expectedTravelTimeLabel.text = "Arrived"
            expectedTravelTimeLabel.isHidden = false
        } else {
            expectedTravelTimeLabel.isHidden = true
        }
        
        dotColorLabel.textColor        = String.convertToColorFromString(string: member.mapMarkerColor)
        if member.isOrganizer == false {
            isOrganizerLabel.isHidden     = true
        } else {
            isOrganizerLabel.isHidden     = false
        }
    }
} //: CLASS
