//
//  GameStatistics.swift
//  ProMind
//
//  Created by Tan Wee Keat on 11/7/21.
//

import UIKit

struct GameStatistics {
    var numCirclesLeft: Int = 25
    var numErrors: Int = 0
    var numLifts: Int = 0
    var totalTimeTaken: Int = 0
    
    func getFormattedGameStats() -> NSMutableAttributedString {
        let statsText = NSMutableAttributedString.init()
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]

        let circlesText = NSMutableAttributedString(string: "Circles Left: ", attributes: attrs)
        circlesText.append(NSMutableAttributedString(string: "\(String(format: "%02d", numCirclesLeft))\n"))
        
        let errorsText = NSMutableAttributedString(string: "Errors: ", attributes: attrs)
        errorsText.append(NSMutableAttributedString(string: "\(String(format: "%02d", numErrors))\n"))
        
        let liftsText = NSMutableAttributedString(string: "Lifts: ", attributes: attrs)
        liftsText.append(NSMutableAttributedString(string: String(format: "%02d", numLifts)))
        
        statsText.append(circlesText)
        statsText.append(errorsText)
        statsText.append(liftsText)
        
        return statsText
    }
}
