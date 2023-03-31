//
//  Strings.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/6/21.
//

import UIKit

struct K {
    static let appName = "ProMind"
    static let charIntervalRate = 0.15
    
    static let fontTypeNormal = "HelveticaNeue"
    static let fontTypeMedium = "HelveticaNeue-Medium"
    static let borderWidthThin: CGFloat = 1.5
    static let borderWidth: CGFloat = 2.0
    static let animateDuration: TimeInterval = 0.30
    static let animateAlpha: CGFloat = 0.25
    
    static let goToExperimentProfileSegue = "InitialToExperimentProfile"
    static let goToTestSelectionSegue = "ExperimentProfileToTestSelection"
    static let goToTMTSegue = "MainToTMT" // to change
    static let goToDSTSegue = "MainToDST" // to change
        
    struct UtteranceRate {
        static let instruction: Float = 0.35
        static let digits: Float = 0.3 // On average, 1 second per character. Actual rate depends on the length of the character.
    }
    
    struct URL {
        static let createSubject = "http://54.169.58.137/api/subject"
        static let getSubject = "http://54.169.58.137/api/subject"
        static let saveTMTResult = "http://54.169.58.137/api/results/trail-making"
        static let saveDSTResult = "http://54.169.58.137/api/results/digit-span"
    }
    
    struct ExperimentProfile {
        static let experimentType = "experimentType"
        static let age = "age"
        static let gender = "gender"
        static let educationLevel = "educationLevel"
        static let ethnicity = "ethnicity"
        
        static let annualIncome = "annualIncome"
        static let patientId = "patientId"
        static let remarks = "generalNote"
        
        struct Master {
            static let questions = [
                K.ExperimentProfile.experimentType: [ExperimentType.Trial.rawValue, ExperimentType.Test.rawValue],
                K.ExperimentProfile.educationLevel: ["No Formal Education", "Primary 6 and Below", "Secondary 5 and Below", "ITE Diploma", "A-Level/Higher Level Certificate", "Polytechnic Diploma", "Bachelor's Degree", "Postgraduate Degree (Masters and Above)"],
                K.ExperimentProfile.ethnicity: ["Chinese", "Malay", "Indian", "Others"],
                K.ExperimentProfile.annualIncome: ["Do not wish to disclose", "No income", "Below 10000", "10000-19999", "20000-29999", "30000-39999", "40000-49999", "50000-59999", "60000-79999", "80000-99999", "100000-119999", "120000-149999", "150000-199999", "200000 and above"],
            ]
        }

        struct Detail {
            static let sectionTitles = [
                K.ExperimentProfile.experimentType: "Experiment Type",
                K.ExperimentProfile.educationLevel: "Education Level",
                K.ExperimentProfile.ethnicity: "Ethnicity",
                K.ExperimentProfile.annualIncome: "Annual Income"
            ]
            static let remarksPlaceholder = "Remarks"
        }
    }
    
    struct TMT {
        static let labels = [
            ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25"],
            ["1","A","2","B","3","C","4","D","5","E","6","F","7","G","8","H","9","I","10","J","11","K","12","L","13"]
        ]
        
        static let tutNumCircles = 10
        
        // Number of circles to total time mapping - time in seconds
        static let numCirclesTimeMapping = [
            10: 120,
            15: 180,
            20: 240,
            25: 300
        ]
        
        static let TrailMakingTest = "Trail Making Test"
        static let goToTMTGameSegue = "TMTMainToTMTGame"
        static let goToTMTResultSegue = "TMTGameToTMTResult"
        
        static let drawSize: CGFloat = 5.0
        static let drawColor = UIColor.blue
        
        /*
        static let instructions = [
            [
//                "0", "1", "2", "3", "4", "5", "6", "7",
                "There are two subtests in Trail Making Test.", // 0
                "Let's start with Trail Making Test A.", // 1
                "Look at the circles below.\nYou have to connect them in ascending order, without lifting the stylus, as much as possible.", // 2
                "For example, 1 has to be connected to 2.", // 3
                "Next, 2 has to be connected to 3.", // 4
                "Then, 3 needs to be connected to 4.", // 5
                "Now, try to connect 4 to 5.", // 6
                "Good job! Please complete the rest on your own!", // 7
                "Well done! You may now begin the test or restart the tutorial." // 8
            ],
            [
//                "0", "1", "2", "3", "4", "5", "6", "7",
                "Well done on completing Trail Making Test A.", // 0
                "Let us proceed with Trail Making Test B.", // 1
                "Look at the circles with numbers and letters below.\nYou have to connect them in the alternating sequence, without lifting the stylus, as much as possible.", // 2
                "For example, 1 has to be connected to A.", // 3
                "Next, A has to be connected to 2.", // 4
                "Then, 2 needs to be connected to B.", // 5
                "Now, try to connect B to 3.", // 6
                "Good job! Please complete the rest on your own!", // 7
                "Well done! You may now begin the test or restart the tutorial." // 8
            ]
        ]
         */
        
        static let instructions = [
            [
//                "0", "1", "2", "3", "4", "5", "6", "7",
                "Look at the circles below. ", // 0
                "The circles have numbers in them. ", // 1
                "Begin at number 1, ", // 2
                "draw a line in ascending order from 1 to 2, ", // 3
                "2 to 3, ", // 4
                "3 to 4, ", // 5
                "and so on, until you reach the end. ", // 6
                "Draw the lines as fast as you can. ", // 7
                "Do not lift the pencil from the iPad. ", // 8
                "Ready? ", // 9
                "Begin! ", // 10
                "Good job! Now let's do the actual test! " // 11
            ],
            [
//                "0", "1", "2", "3", "4", "5", "6", "7",
                "On this page there are both numbers and letters. ", // 0
                "Do this in the same way. ", // 1
                "Begin at number 1, ", // 2
                "draw a line from 1 to A, ", // 3
                "A to 2, ", // 4
                "2 to B, ", // 5
                "and so on, until you reach the end. ", // 6
                "Draw the lines as fast as you can. ", // 7
                "Do not lift the pencil from the iPad. ", // 8
                "Ready? ", // 9
                "Begin! ", // 10
                "Good job! Now let's do the actual test! " // 11
            ]
        ]
        
        static let mistakeMessages = "That is not the correct move!"
        static let finishMessage = "Congratulations. You have completed the Trail Making Test. Please refer to your results on the screen."
    }
    
    struct DST {
        static let DigitSpanTest = "Digit Span Test"
        static let goToDSTResultSegue = "GameToDSTResult"
        
        static let instructions = [
//            "-1", "0", "1", "2",
            "There are three subtests in Digit Span Test. We will go through them one by one.",

            "First, we will start with Digit Forward.\n\n" +
            "In this subtest, a series of numbers will be presented to you, and you need to VERBALLY repeat the numbers in the EXACT sequence as presented, within ONE minute.\n\n" +
            "Once repeated, you can press the 'Submit Answer' button to proceed to the next question, or you may press the 'Reset Answer' button to reset your answer again.\n\n" +
            "When you are ready, press 'Start'.",

            "Next, we will proceed with Digit Backward.\n\n" +
            "In this subtest, a series of numbers will be presented to you, and you need to VERBALLY repeat the numbers in the REVERSE order as presented, within ONE minute.\n\n" +
            "As an example, if the number is 3 7 2 5, you need to repeat as 5 2 7 3.\n\n" +
            "Once repeated, you can press the 'Submit Answer' button to proceed to the next question, or you may press the 'Reset Answer' button to reset your answer again.\n\n" +
            "When you are ready, press 'Start'.",

            "Finally, we will end with Digit Sequencing.\n\n" +
            "In this subtest, a series of numbers will be presented to you, and you need to VERBALLY repeat the numbers in ASCENDING order, within ONE minute.\n\n" +
            "As an example, if the number is 7 2 4 3, you need to repeat as 2 3 4 7.\n\n" +
            "Once repeated, you can press the 'Submit Answer' button to proceed to the next question, or you may press the 'Reset Answer' button to reset your answer again.\n\n" +
            "When you are ready, press 'Start'."
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
        
        static let finishMessage = "Congratulations. You have completed the Digit Span Test. Please refer to your results on the screen."
    }
}
