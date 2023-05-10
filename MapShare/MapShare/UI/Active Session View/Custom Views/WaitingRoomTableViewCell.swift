//
//  WaitingRoomTableViewCell.swift
//  MapShare
//
//  Created by iMac Pro on 5/9/23.
//

import UIKit

class WaitingRoomTableViewCell: UITableViewCell {

    //MARK: - OUTLETS
    @IBOutlet weak var waitingRoomMemberNameLabel: UILabel!
    @IBOutlet weak var waitingRoomScreenNameLabel: UILabel!
    @IBOutlet weak var denyNewMemberButton: UIButton!
    @IBOutlet weak var admitNewMemberButton: UIButton!

    
    //MARK: - IB ACTIONS
    @IBAction func denyNewMemberButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func admitNewMemberButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK: - FUNCTIONS
    func configureWaitingRoomCell(withMember member: Member) {
        waitingRoomMemberNameLabel.text = "\(member.firstName) \(member.lastName)"
        waitingRoomScreenNameLabel.text = member.screenName
        
        UIElements.configureButton(for: denyNewMemberButton, withColor: UIElements.Color.mapShareRed)
        UIElements.configureButton(for: admitNewMemberButton, withColor: UIElements.Color.mapShareGreen)
    }
} //: CLASS
