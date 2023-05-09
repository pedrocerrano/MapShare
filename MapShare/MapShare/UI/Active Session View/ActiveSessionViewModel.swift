//
//  ActiveSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import Foundation

class ActiveSessionViewModel {
    
    //MARK: - PROPERTIES
    var session: Session
    var service: FirebaseService
    let sectionTitles = ["Active Members", "Waiting Room"]
    
    init(session: Session, service: FirebaseService = FirebaseService()) {
        self.session = session
        self.service = service
    }
    
    //MARK: - FUNCTIONS
    func loadSession() {
        service.loadSessionFromFirestore(forSession: session) { result in
            switch result {
            case .success(let loadedSession):
                guard let loadedSession else { return }
                self.session = loadedSession
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteSession() {
        service.deleteSessionFromFirestore(session: session)
    }
}
