//
//  Strings.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/6/21.
//

import Foundation

struct K {
    static let goToTMTSegue = "MainToTMT"
    static let goToDSTSegue = "MainToDST"
    
    struct TMT {
        static let TrailMakingTest = "Trail Making Test"
        static let totalTime = 120 // Time in seconds
        static let goToTMTResultSegue = "GameToTMTResult"
    }
    
    struct DST {
        static let DigitSpanTest = "Digit Span Test"
        static let goToDSTResultSegue = "GameToDSTResult"
        
        static let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        // Mappings of number of trials to number of digits       
        static let numDigitsMapping = [
             1:3,  2:3,
             3:4,  4:4,
             5:5,  6:5,
             7:6,  8:6,
             9:7, 10:7,
            11:8, 12:8
        ]
        
//        static let numDigitsMapping = [
//            1:3, 2:4, 3:5, 4:6, 5:7, 6:8
//        ]
        
//        static let maxAnswerTime = 15
    }
}
