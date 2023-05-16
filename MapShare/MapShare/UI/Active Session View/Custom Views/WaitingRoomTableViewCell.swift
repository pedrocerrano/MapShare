//
//  WaitingRoomTableViewCell.swift
//  MapShare
//
//  Created by iMac Pro on 5/9/23.
//

import UIKit

protocol WaitingRoomTableViewCellDelegate: AnyObject {
    func admitMember(forSession session: Session, forMember member: Member)
    func denyMember(fromSession session: Session, forMember member: Member)
}

class WaitingRoomTableViewCell: UITableViewCell {

    //MARK: - OUTLETS
    @IBOutlet weak var waitingRoomMemberNameLabel: UILabel!
    @IBOutlet weak var waitingRoomScreenNameLabel: UILabel!
    @IBOutlet weak var denyNewMemberButton: UIButton!
    @IBOutlet weak var admitNewMemberButton: UIButton!

    
    //MARK: - PROPERTIES
    var member: Member?
    var session: Session?
    weak var delegate: WaitingRoomTableViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        member   = nil
        session  = nil
        delegate = nil
    }
    
    //MARK: - IB ACTIONS
    @IBAction func admitNewMemberButtonTapped(_ sender: Any) {
        guard let member = member,
              let session = session else { return }
        delegate?.admitMember(forSession: session, forMember: member)
    }
    
    @IBAction func denyNewMemberButtonTapped(_ sender: Any) {
        guard let member = member,
              let session = session else { return }
        delegate?.denyMember(fromSession: session, forMember: member)
    }
        
    
    //MARK: - FUNCTIONS
    func configureWaitingRoomCell(forSession session: Session, withMember member: Member, delegate: WaitingRoomTableViewCellDelegate) {
        waitingRoomMemberNameLabel.text = "\(member.firstName) \(member.lastName)"
        waitingRoomScreenNameLabel.text = member.screenName
        
        self.member   = member
        self.session  = session
        self.delegate = delegate
        
        UIElements.configureButton(for: admitNewMemberButton, withColor: UIElements.Color.mapShareGreen)
        UIElements.configureButton(for: denyNewMemberButton, withColor: UIElements.Color.mapShareRed)
        if Constants.Device.deviceID != session.organizerDeviceID {
            admitNewMemberButton.isHidden = true
            denyNewMemberButton.isHidden  = true
        }

    }
    
} //: CLASS
