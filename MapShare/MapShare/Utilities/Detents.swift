//
//  Detents.swift
//  MapShare
//
//  Created by iMac Pro on 5/5/23.
//

import UIKit

struct Detents {
    
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
