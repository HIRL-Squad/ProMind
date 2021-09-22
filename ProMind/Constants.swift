//
//  Strings.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/6/21.
//

import UIKit

struct K {
    static let fontTypeNormal = "HelveticaNeue"
    static let fontTypeMedium = "HelveticaNeue-Medium"
    static let borderWidth: CGFloat = 2.0
    static let animateDuration: TimeInterval = 0.30
    static let animateAlpha: CGFloat = 0.25
    
    static let goToSubjectProfileToCreateNewSubjectSegue = "LoadSubjectOptionToSubjectProfileCreateSubject"
    static let goToSubjectProfileToLoadSubjectSegue = "LoadSubjectOptionToSubjectProfileLoadSubject"
    static let goToTestSelectionSegue = "SubjectProfileToTestSelection"
    static let goToTMTSegue = "MainToTMT" // to change
    static let goToDSTSegue = "MainToDST" // to change
        
    struct UtteranceRate {
        static let instruction: Float = 0.4
        static let digits: Float = 0.3 // On average, 1 second per character. Actual rate depends on the length of the character.
    }
    
    struct URL {
        static let createSubject = "http://54.169.58.137/api/subject"
        static let getSubject = "http://54.169.58.137/api/subject"
        static let saveTMTResult = "http://54.169.58.137/api/results/trail-making"
        static let saveDSTResult = "http://54.169.58.137/api/results/digit-span"
    }
    
    struct SubjectProfile {
        static let subjectType = "subjectType"
        static let site = "site"
        static let isPatient = "isPatient"
        static let birthDate = "birthDate"
        static let subjectId = "subjectId"
        static let occupation = "occupation"
        static let gender = "gender"
        static let educationLevel = "educationLevel"
        static let ethnicity = "ethnicity"
        static let dominantHand = "dominantHand"
        static let annualIncome = "annualIncome"
        static let housingType = "housingType"
        static let livingArrangement = "livingArrangement"
        
        static let sarcfScores = "sarcfScores"
        static let question1 = "question1"
        static let question2 = "question2"
        static let question3 = "question3"
        static let question4 = "question4"
        static let question5 = "question5"
        
        static let medicationHistory = "medicationHistory"
        static let charlestonComorbidity = "charlestonComorbidity"
        static let bloodPressure = "bloodPressure"
        static let cholesterolLDL = "cholesterolLDL"
        static let bloodGlucose = "bloodGlucose"
        static let mmseScore = "mmseScore"
        static let mocaScore = "mocaScore"
        static let diagnosis = "diagnosis"
        static let generalNote = "generalNote"
        
        struct Master {
            static let questions = [
                K.SubjectProfile.subjectType: [SubjectType.TRIAL.rawValue, SubjectType.TEST.rawValue],
                K.SubjectProfile.site: ["Lions Befrienders", "Alexandra Hospital", "Outram Community Hospital", "Others"],
                
                K.SubjectProfile.educationLevel: [" ", "No Formal Education", "Primary 6 and Below", "Secondary 5 and Below", "ITE Diploma", "A-Level/Higher Level Certificate", "Polytechnic Diploma", "Bachelor's Degree", "Postgraduate Degree (Masters and Above)"],
                K.SubjectProfile.ethnicity: ["Chinese", "Malay", "Indian", "Others"],
                K.SubjectProfile.dominantHand: [DominantHand.Left.rawValue, DominantHand.Right.rawValue],
                K.SubjectProfile.annualIncome: ["Do not wish to disclose", "No income", "Below 10000", "10000-19999", "20000-29999", "30000-39999", "40000-49999", "50000-59999", "60000-79999", "80000-99999", "100000-119999", "120000-149999", "150000-199999", "200000 and above"],
                K.SubjectProfile.housingType: ["HDB Rental Apartment", "HDB Studio Apartment", "HDB 2-Room Apartment", "HDB 3-Room Apartment", "HDB 4-Room Apartment", "HDB 5-Room/Executive Apartment", "Condominium Apartment", "Landed Property"],
                K.SubjectProfile.livingArrangement: ["Living Alone", "Living with Helper", "Living with Family", "Living in a Nursing Home"],
                
                K.SubjectProfile.question1: ["None (0 point)", "Some (1 point)", "A lot or unable (2 points)"],
                K.SubjectProfile.question2: ["None (0 point)", "Some (1 point)", "A lot, use aids or unable (2 points)"],
                K.SubjectProfile.question3: ["None (0 point)", "Some (1 point)", "A lot or unable (2 points)"],
                K.SubjectProfile.question4: ["None (0 point)", "Some (1 point)", "A lot or unable (2 points)"],
                K.SubjectProfile.question5: ["None (0 point)", "1 to 3 falls (1 point)", "4 or more falls (2 points)"],
            ]
        }

        struct Detail {
            static let sectionTitles = [
                K.SubjectProfile.subjectType: "Subject Type",
                K.SubjectProfile.site: "Site",
                K.SubjectProfile.educationLevel: "Education Level",
                K.SubjectProfile.ethnicity: "Ethnicity",
                K.SubjectProfile.dominantHand: "Dominant Hand",
                K.SubjectProfile.annualIncome: "Annual Income",
                K.SubjectProfile.housingType: "Housing Type",
                K.SubjectProfile.livingArrangement: "Living Arrangement",
                
                K.SubjectProfile.question1: "1. How much difficulty do you have in lifting and carrying a load of 4.5 kg?",
                K.SubjectProfile.question2: "2. How much difficulty do you have walking across a room?",
                K.SubjectProfile.question3: "3. How much difficulty do you have transferring from a chair or a bed?",
                K.SubjectProfile.question4: "4. How much difficulty do you have climbing a flight of 10 stairs?",
                K.SubjectProfile.question5: "5. How many times have you fallen in the last year?",
            ]
        }
    }
    
    struct TMT {
        static let labels = [
            ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25"],
            ["1","A","2","B","3","C","4","D","5","E","6","F","7","G","8","H","9","I","10","J","11","K","12","L","13"]
        ]
        
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
        
        static let instructions = [
            [
//                "0", "1", "2", "3", "4", "5", "6", "7",
                "There are two subtests in Trail Making Test.", // 0
                "Let's start with Trail Making Test A.", // 1
                "Look at the circles below. You have to connect them in ascending order.", // 2
                "For example, 1 has to be connected to 2.", // 3
                "Then, 2 has to be connected to 3.", // 4
                "Now, try to connect 3 to 4.", // 5
                "Good job! Please complete the rest on your own!", // 6
                "Well done! You may now begin the test or restart the tutorial." // 7
            ],
            [
//                "0", "1", "2", "3", "4", "5", "6", "7",
                "Well done on completing Trail Making Test A.", // 0
                "Let us proceed with Trail Making Test B.", // 1
                "Look at the circles with numbers and letters below. You have to connect them in the alternating sequence.", // 2
                "For example, 1 has to be connected to A.", // 3
                "Then, A has to be connected to 2.", // 4
                "Now, try to connect 2 to B.", // 5
                "Good job! Please complete the rest on your own!", // 6
                "Well done! You may now begin the test or restart the tutorial." // 7
            ]

        ]
        
        static let mistakeMessages = "That is not the correct move!"
        static let finishMessage = "Congratulations. You have completed the Trail Making Test. Please refer to your results on the screen."
    }
    
    struct DST {
        static let DigitSpanTest = "Digit Span Test"
        static let goToDSTResultSegue = "GameToDSTResult"
        
//        static let instructions = [
//            "There are three subtests in Digit Span Test. We will go through them one by one.",
//            "First, we will start with Digit Forward. In this subtest, a series of numbers will be presented to you, and you need to repeat the numbers in the exact sequence as presented within 1 minute. Once repeated, you can press the Done button to proceed to the next question, or you may press the Reset Input button to repeat the numbers again. When you are ready, press Start.",
//            "Next, we will proceed with Digit Backward. In this subtest, a series of numbers will be presented to you, and you need to repeat the numbers in the reverse order as presented, within 1 minute. For example, if the number is 3 7 2, you need to repeat as 2 7 3. Once repeated, you can press the Done button to proceed to the next question, or you may press the Reset Input button to repeat the numbers again. When you are ready, press Start.",
//            "Finally, we will start with Digit Sequencing. In this subtest, a series of numbers will be presented to you, and you need to repeat the numbers in ascending order, within 1 minute. For example, if the number is 7 2 4, you need to repeat as 2 4 7. Once repeated, you can press the Done button to proceed to the next question, or you may press the Reset Input button to repeat the numbers again. When you are ready, press Start."
//        ]
        
        static let instructions = [
            "-1",
            "0",
            "1",
            "2",
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
