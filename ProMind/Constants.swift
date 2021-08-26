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
        
//        static let instructions = [
//            "There are a total of three subtests in Digit Span Test. We will go through them one by one.",
//            "First, we will start with Digit Forward. In this subtest, a series of numbers will be presented to you, and you need to repeat the numbers in the exact sequence as presented within 1 minute. Once repeated, you can press the Done button to proceed to the next question, or you may press the Reset Input button to repeat the numbers again. When you are ready, press Start.",
//            "Next, we will proceed with Digit Backward. In this subtest, a series of numbers will be presented to you, and you need to repeat the numbers in the reverse order as presented, within 1 minute. For example, if the number is 3 7 2, you need to repeat as 2 7 3. Once repeated, you can press the Done button to proceed to the next question, or you may press the Reset Input button to repeat the numbers again. When you are ready, press Start.",
//            "Finally, we will start with Digit Sequencing. In this subtest, a series of numbers will be presented to you, and you need to repeat the numbers in ascending order, within 1 minute. For example, if the number is 7 2 4, you need to repeat as 2 4 7. Once repeated, you can press the Done button to proceed to the next question, or you may press the Reset Input button to repeat the numbers again. When you are ready, press Start."
//        ]
        
        static let instructions = [
            "Instruction -1",
            "Instruction 0",
            "Instruction 1",
            "Instruction 2",
        ]
        
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
    }
}
