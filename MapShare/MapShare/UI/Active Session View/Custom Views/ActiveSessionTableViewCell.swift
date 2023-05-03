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
    @IBOutlet weak var isOrganizerImageView: UIImageView!
    @IBOutlet weak var dotColorImageView: UIImageView!
    
    
    //MARK: - FUNCTIONS
    func configureCell(with member: Member) {
        memberNameLabel.text = member.memberName
        if member.isOrganizer == false {
            isOrganizerImageView.isHidden = true
        }
        
    }
    

}
