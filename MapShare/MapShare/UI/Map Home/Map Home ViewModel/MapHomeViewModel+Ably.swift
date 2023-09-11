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
        ablyRealtimeClient = ARTRealtime(key: Constants.Ably.apiKey)
        ablyRealtimeClient.connection.on { state in
            switch state.current {
            case .connected:
                self.subscribeToAblyChannel(mapShareSession: mapShareSession)
                print("Success connecting to the Ably API!")
            case .failed:
                NotificationCenter.default.post(name: Constants.Notifications.ablyRealtimeServer, object: nil)
            default:
                break
            }
        }
    }
    
    func subscribeToAblyChannel(mapShareSession: Session) {
        ablyChannel = ablyRealtimeClient.channels.get(mapShareSession.sessionCode)
        ablyChannel.subscribe { message in
            self.delegate?.ablyMessagesUpdate(message: message)
        }
    }
}
