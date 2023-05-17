//
//  ActiveSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import UIKit

class ActiveSessionViewController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var sessionControlButton: UIButton!
    @IBOutlet weak var activeSessionTableView: UITableView!
    
    
    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var activeSessionViewModel: ActiveSessionViewModel!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        activeSessionTableView.dataSource = self
        activeSessionTableView.delegate   = self
        configureUI()
        configureSheetPresentationController()
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[1].identifier
        }
        activeSessionViewModel.updateSession()
        activeSessionViewModel.updateMembers()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func sessionControlButtonTapped(_ sender: Any) {
        if Constants.Device.deviceID == activeSessionViewModel.session.organizerDeviceID {
            organizerEndedActiveSessionAlert()
        } else {
            memberExitsActiveSessionAlert()
        }
    }
    
    
    //MARK: - FUNCTIONS
    func configureUI() {
        let session = activeSessionViewModel.session
        sessionNameLabel.text = session.sessionName
        sessionCodeLabel.text = session.sessionCode
        
        sessionControlButton.layer.cornerRadius = sessionControlButton.frame.height / 2
    }
    
    func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    
    
    //MARK: - ALERTS
    func organizerEndedActiveSessionAlert() {
        let organizerEndedActiveSessionAlertController = UIAlertController(title: "End Session?", message: "Press 'Confirm' to end MapShare for all members.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { alert in
            for member in self.activeSessionViewModel.session.members {
                self.activeSessionViewModel.deleteMemberFromActiveSession(fromSession: self.activeSessionViewModel.session, forMember: member)
            }
            self.activeSessionViewModel.deleteSession()
            #warning("Add Alert for other members that the organizer ended the session, and consider a completion handler to do so")
            self.sheetPresentationController.animateChanges {
                self.sheetPresentationController.dismissalTransitionWillBegin()
            }
        }
        organizerEndedActiveSessionAlertController.addAction(dismissAction)
        organizerEndedActiveSessionAlertController.addAction(confirmAction)
        present(organizerEndedActiveSessionAlertController, animated: true)
    }
    
    func memberExitsActiveSessionAlert() {
        let memberExitsActiveSessionAlertController = UIAlertController(title: "Exit Session?", message: "Press 'Confirm' to exit MapShare.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { alert in
            guard let member = self.activeSessionViewModel.session.members.filter({ $0.memberDeviceID == Constants.Device.deviceID }).first else { return }
            self.activeSessionViewModel.deleteMemberFromActiveSession(fromSession: self.activeSessionViewModel.session, forMember: member)
            self.sheetPresentationController.animateChanges {
                self.sheetPresentationController.dismissalTransitionWillBegin()
            }
        }
        memberExitsActiveSessionAlertController.addAction(dismissAction)
        memberExitsActiveSessionAlertController.addAction(confirmAction)
        present(memberExitsActiveSessionAlertController, animated: true)
    }
} //: CLASS


//MARK: - EXT: TableViewDataSource and Delegate
extension ActiveSessionViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return activeSessionViewModel.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return activeSessionViewModel.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return activeSessionViewModel.session.members.filter { $0.isActive == true }.count
        case 1:
            return activeSessionViewModel.session.members.filter { $0.isActive == false }.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let activeCell = tableView.dequeueReusableCell(withIdentifier: "activeMemberCell", for: indexPath) as? ActiveSessionTableViewCell else { return UITableViewCell() }
            
            let member = activeSessionViewModel.session.members.filter { $0.isActive == true }[indexPath.row]
            activeCell.configureCell(with: member)
            
            return activeCell
        case 1:
            guard let waitingRoomCell = tableView.dequeueReusableCell(withIdentifier: "waitingMemberCell", for: indexPath) as? WaitingRoomTableViewCell else { return UITableViewCell() }
            
            let activeSession = activeSessionViewModel.session
            let member        = activeSessionViewModel.session.members.filter { $0.isActive == false }[indexPath.row]
            waitingRoomCell.configureWaitingRoomCell(forSession: activeSession, withMember: member, delegate: self)
            
            return waitingRoomCell
        default:
            break
        }
        
        // The line below shouldn't hit because of how the switch handled the returned cells above.
        return UITableViewCell()
    }
} //: TableView


//MARK: - EXT: ViewModelDelegate
extension ActiveSessionViewController: ActiveSessionViewModelDelegate {   
    func sessionDataUpdated() {
        activeSessionTableView.reloadData()
    }
    
    func memberDataUpdated() {
        activeSessionTableView.reloadData()
    }
} //: ViewModelDelegate


//MARK: - EXT: WaitingRoomCellDelegate
extension ActiveSessionViewController: WaitingRoomTableViewCellDelegate {
    func admitMember(forSession session: Session, forMember member: Member) {
        self.activeSessionViewModel.admitNewMember(forSession: session, withMember: member)
    }
    
    func denyMember(fromSession session: Session, forMember member: Member) {
        self.activeSessionViewModel.denyNewMember(forSession: session, withMember: member)
    }
} //: WaitingRoomCellDelegate
