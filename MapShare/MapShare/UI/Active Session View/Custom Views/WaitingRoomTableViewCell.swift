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

    
    //MARK: - PROPERTIES
    var admitButtonTapped: (() -> ()) = {}
    var denyButtonTapped: (() -> ()) = {}
    
    
    //MARK: - IB ACTIONS
    @IBAction func admitNewMemberButtonTapped(_ sender: Any) {
        admitButtonTapped()
    }
    
    @IBAction func denyNewMemberButtonTapped(_ sender: Any) {
        denyButtonTapped()
    }
        
    
    //MARK: - FUNCTIONS
    func configureWaitingRoomCell(forSession session: Session, withMember member: Member) {
        waitingRoomMemberNameLabel.text = "\(member.firstName) \(member.lastName)"
        waitingRoomScreenNameLabel.text = member.screenName
        
        
        UIElements.configureButton(for: admitNewMemberButton, withColor: UIElements.Color.mapShareGreen)
        UIElements.configureButton(for: denyNewMemberButton, withColor: UIElements.Color.mapShareRed)
        if Constants.Device.deviceID != session.organizerDeviceID {
            admitNewMemberButton.isHidden = true
            denyNewMemberButton.isHidden  = true
        }

    }
    
} //: CLASS
