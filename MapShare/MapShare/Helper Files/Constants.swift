//
//  Constants.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

struct Constants {
    
    struct Detents {
//        static let bottomDetentMultipler    = 0.09
//        static let middleDetentMultiplier   = 0.345
//        static let topDetentMultiplier      = 0.875
        
        static func buildDetent(screenHeight: CGFloat) -> [UISheetPresentationController.Detent] {
            let bottomDetent = UISheetPresentationController.Detent.custom { context in
                screenHeight * 0.09
            }
            
            let middleDetent = UISheetPresentationController.Detent.custom { context in
                screenHeight * 0.345
            }
            
            let topDetent = UISheetPresentationController.Detent.custom { context in
                screenHeight * 0.875
            }
            
            return [bottomDetent, middleDetent, topDetent]
        }
    }
    

}
