//
//  ActiveSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import UIKit

class ActiveSessionViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var sessionControlButton: UIButton!
    @IBOutlet weak var activeSessionTableView: UITableView!
    @IBOutlet weak var inviteMembersButton: UIButton!
    
    
    //MARK: - Properties
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var activeSessionViewModel: ActiveSessionViewModel!
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activeSessionTableView.dataSource = self
        activeSessionTableView.delegate   = self
        configureUI()
        activeSessionViewModel.configureListeners()
        configureSheetPresentationController()
        setupNotifications()
        inviteMembersButton.addTarget(self, action: #selector(presentShareSheet), for: .touchUpInside)
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[1].identifier
        }
    }
    
    
    //MARK: - IB Actions
    @IBAction func sessionControlButtonTapped(_ sender: Any) {
        if Constants.Device.deviceID == activeSessionViewModel.session.organizerDeviceID {
            organizerEndingSessionAlert()
        } else {
            memberExitsAlert()
        }
    }
    
    
    //MARK: - Functions
    @objc func presentShareSheet(_ sender: UIButton) {
        guard let organizer = activeSessionViewModel.session.members.filter ({ $0.isOrganizer }).first else { return }
        let shareMessage    = "\(String(describing: organizer.title)) is inviting you to a MapShare Session! Join with code: \(activeSessionViewModel.session.sessionCode)"
        let shareSheetVC    = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        shareSheetVC.popoverPresentationController?.sourceView = sender
        shareSheetVC.popoverPresentationController?.sourceRect = sender.frame
        present(shareSheetVC, animated: true)
    }
    
    private func configureUI() {
        let session = activeSessionViewModel.session
        sessionNameLabel.text = session.sessionName
        sessionCodeLabel.text = session.sessionCode
        
        UIElements.configureFilledStyleButtonAttributes(for: inviteMembersButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureCircleButtonAttributes(for: sessionControlButton, backgroundColor: .systemRed, tintColor: .white)
        if let _ = session.members.filter ({ $0.isOrganizer }).first {
            inviteMembersButton.isHidden = false
        } else {
            inviteMembersButton.isHidden = true
        }
    }
    
    private func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
        sheetPresentationController.presentedViewController.isModalInPresentation = true
    }
    
    
    //MARK: - Alerts
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ablyRealtimeServerIssue), name: Constants.Notifications.locationAccessNeeded, object: nil)
    }
    
    @objc func ablyRealtimeServerIssue() {
        present(AlertControllers.ablyRealtimeServerIssue(), animated: true, completion: nil)
    }
    
    private func organizerEndingSessionAlert() {
        let organizerEndingSessionAlertController = UIAlertController(title: "End Session?", message: "Press 'Confirm' to end MapShare for all members.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.activeSessionViewModel.deleteSessionAndMemberDocuments()
            self.activeSessionViewModel.removeListeners()
            self.activeSessionViewModel.mapHomeDelegate?.noSessionActive()
            self.sheetPresentationController.animateChanges {
                self.sheetPresentationController.dismissalTransitionWillBegin()
            }
        }
        organizerEndingSessionAlertController.addAction(dismissAction)
        organizerEndingSessionAlertController.addAction(confirmAction)
        present(organizerEndingSessionAlertController, animated: true)
    }
    
    private func memberExitsAlert() {
        let memberExitsAlertController = UIAlertController(title: "Exit Session?", message: "Press 'Confirm' to exit MapShare.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self   = self,
                  let member = self.activeSessionViewModel.session.members.filter({ $0.deviceID == Constants.Device.deviceID }).first
            else { return }
            
            self.activeSessionViewModel.deleteMemberSelf(fromSession: self.activeSessionViewModel.session, forMember: member)
            self.activeSessionViewModel.removeListeners()
            self.activeSessionViewModel.mapHomeDelegate?.noSessionActive()
            self.sheetPresentationController.animateChanges {
                self.sheetPresentationController.dismissalTransitionWillBegin()
            }
        }
        memberExitsAlertController.addAction(dismissAction)
        memberExitsAlertController.addAction(confirmAction)
        present(memberExitsAlertController, animated: true)
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
            return activeSessionViewModel.session.members.filter { $0.isActive }.count
        case 1:
            return activeSessionViewModel.session.members.filter { !$0.isActive }.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let activeCell = tableView.dequeueReusableCell(withIdentifier: "activeMemberCell", for: indexPath) as? ActiveSessionTableViewCell else { return UITableViewCell() }
            
            let activeSession = activeSessionViewModel.session
            let member        = activeSession.members.filter { $0.isActive }[indexPath.row]
            activeCell.configureCell(forSession: activeSession, with: member)
            
            return activeCell
        case 1:
            guard let waitingRoomCell = tableView.dequeueReusableCell(withIdentifier: "waitingMemberCell", for: indexPath) as? WaitingRoomTableViewCell else { return UITableViewCell() }

            let activeSession = activeSessionViewModel.session
            let member        = activeSession.members.filter { !$0.isActive }[indexPath.row]
            waitingRoomCell.configureWaitingRoomCell(forSession: activeSession, withMember: member, delegate: self)
            
            return waitingRoomCell
        default:
            break
        }
        
        return UITableViewCell()
    }
} //: TableView


//MARK: - EXT: ViewModelDelegate
extension ActiveSessionViewController: ActiveSessionViewModelDelegate {   
    func sessionDataUpdated() {
        activeSessionTableView.reloadData()
    }
    
    func sessionReturnedNil() {
        sheetPresentationController.dismissalTransitionWillBegin()
        activeSessionViewModel.mapHomeDelegate?.noSessionActive()
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
