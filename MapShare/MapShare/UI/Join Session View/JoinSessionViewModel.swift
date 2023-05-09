//
//  JoinSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/8/23.
//

import Foundation

protocol JoinSessionViewModelDelegate: AnyObject {
    func sessionExists()
    func noSessionFoundWithCode()
}

class JoinSessionViewModel {
    
    //MARK: - PROPERTIES
    var service: FirebaseService
    private weak var delegate: JoinSessionViewModelDelegate?
    
    init(service: FirebaseService = FirebaseService(), delegate: JoinSessionViewModelDelegate) {
        self.service  = service
        self.delegate = delegate
    }
    
    
    //MARK: - FUNCTIONS
    func searchFirebase(with code: String) {
        service.searchFirebaseForActiveSession(withCode: code) { result in
            switch result {
            case .success(let bool):
                if bool == true {
                    self.delegate?.sessionExists()
                } else {
                    self.delegate?.noSessionFoundWithCode()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
