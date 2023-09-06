//
//  MapHomeViewModel+Ably.swift
//  MapShare
//
//  Created by iMac Pro on 9/6/23.
//

import Foundation
import Ably

extension MapHomeViewModel {
    
    //MARK: - Functions
    func connectToAbly(mapShareSession: Session) {
        client = ARTRealtime(key: Constants.Ably.apiKey)
        client.connection.on { state in
            switch state.current {
            case .connected:
                self.subscribeToAblyChannel(mapShareSession: mapShareSession)
                print("Success connecting to the API!")
            case .failed:
                print("There was a problem connecting to the Ably")
            default:
                break
            }
        }
    }
    
    func subscribeToAblyChannel(mapShareSession: Session) {
        channel = client.channels.get(mapShareSession.sessionCode)
        channel.subscribe { message in
            self.delegate?.ablyMessagesUpdate(message: message)
        }
    }
}
