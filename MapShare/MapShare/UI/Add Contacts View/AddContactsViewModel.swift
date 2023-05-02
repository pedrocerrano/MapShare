//
//  AddContactsViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/1/23.
//

import UIKit
import Contacts

protocol AddContactsViewModelDelegate: AnyObject {
    func accessToContactsDenied()
}

struct AddContactsViewModel {
    
    //MARK: - PROPERTIES
    let session: Session
    var contactStore = CNContactStore()
    private weak var delegate: AddContactsViewModelDelegate?
        
    init(session: Session, delegate: AddContactsViewModelDelegate) {
        self.session  = session
        self.delegate = delegate
    }
    
    //MARK: - FUNCTIONS
    func requestAccess(completion: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completion(true)
        case .denied:
            delegate?.accessToContactsDenied()
        case .restricted, .notDetermined:
            contactStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completion(true)
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.accessToContactsDenied()
                    }
                }
            }
        @unknown default:
            fatalError()
        }
    }
}
