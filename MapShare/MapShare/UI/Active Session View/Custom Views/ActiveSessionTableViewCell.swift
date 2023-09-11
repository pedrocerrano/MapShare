//
//  ActiveSessionTableViewCell.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import UIKit

class ActiveSessionTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberScreenNameLabel: UILabel!
    @IBOutlet weak var isOrganizerLabel: UILabel!
    @IBOutlet weak var transportTypeLabel: UILabel!
    @IBOutlet weak var expectedTravelTimeLabel: UILabel!
    @IBOutlet weak var dotColorLabel: UILabel!
    
    
    //MARK: - Functions
    func configureCell(forSession session: Session, with member: Member) {
        memberNameLabel.text       = "\(member.firstName) \(member.lastName)"
        memberScreenNameLabel.text = member.title
        isOrganizerLabel.textColor = UIElements.Color.mapShareYellow
        dotColorLabel.textColor    = Member.convertToColorFromString(string: member.color)
        
        guard let timeAsDouble = member.expectedTravelTime else { return }
        
        if timeAsDouble > 0 {
            expectedTravelTimeLabel.text     = timeAsString(timeAsDouble, style: .abbreviated)
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
        
        if let routeAnnotation = session.routes.first {
            if routeAnnotation.isDriving {
                transportTypeLabel.text = "Driving ETA"
            } else {
                transportTypeLabel.text = "Walking ETA"
            }
        }
    }
    
    private func timeAsString(_ timeAsDouble: Double, style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = style
        return formatter.string(from: timeAsDouble) ?? "Formatter Failure"
    }
} //: CLASS
