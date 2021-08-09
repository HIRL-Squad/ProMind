//
//  GameStatistics.swift
//  ProMind
//
//  Created by Tan Wee Keat on 11/7/21.
//

import UIKit

struct DSTGameStatistics {
    var totalTime = 0
    var numCorrectTrials = 0
    
    var currentSequence = 0 // Helper variable as a tracker
    var longestSequence = 0
    
    var maxDigits = 3
    
    func getFormattedGameStats(fontSize: CGFloat = 16) -> NSMutableAttributedString {
        let statsText = NSMutableAttributedString.init()
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize)]

        let timeTakenText = NSMutableAttributedString(string: "Time Taken: ", attributes: attrs)
        timeTakenText.append(NSMutableAttributedString(string: "\(totalTime) s\n"))
        
        let maxDigitsText = NSMutableAttributedString(string: "Max Digits: ", attributes: attrs)
        maxDigitsText.append(NSMutableAttributedString(string: "\(maxDigits)\n"))
        
        let numCorrectTrialsText = NSMutableAttributedString(string: "Correct Trials: ", attributes: attrs)
        numCorrectTrialsText.append(NSMutableAttributedString(string: "\(numCorrectTrials)\n"))
        
        let longestSequenceText = NSMutableAttributedString(string: "Longest Seq: ", attributes: attrs)
        longestSequenceText.append(NSMutableAttributedString(string: "\(longestSequence)"))
    
        statsText.append(timeTakenText)
        statsText.append(maxDigitsText)
        statsText.append(numCorrectTrialsText)
        statsText.append(longestSequenceText)
        
        return statsText
    }
}
