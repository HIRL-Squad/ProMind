//
//  DSTInstructions.swift
//  ProMind
//
//  Created by HAIKUO YU on 22/4/22.
//

import Foundation

/** Digit Span includes two tasks: Forward and Backward Span **/

struct DigitSpanTest: Identifiable {
    var id = UUID()
    // let dstConstants: K.DST
    
    /// For the Forward task, the individual repeats numbers uttered by the tablet in the same order.
    let forwardNumberSpanInstructions = [
        "This is part of your memory and concentration task. ", /// 0
        "You will hear some numbers. ",
        "Once done, you will hear a bell, like so: ",
        "(Bell Sound)",
        "After you hear the bell, repeat the numbers in the same order.\n\nPlease speak slowly. Do not rush or repeat answers.",
        "For example, if you hear: ",
        "1 - 8 - 7",
        "You would say: ",
        "1 - 8 - 7",
        "Remember to speak as slowly as one second per digit, like how the example did.\n\nNever rush or repeat answers.",
        "If you hear: ",
        "2 – 9 – 8",
        "What would you say? ",
        
        // If the user gives the wrong answer. Skip if correct answer is given.
        "That is incorrect, you would say: ", /// 12
        "2 – 9 – 8",
        
        // If the user gives the correct answer.
        "Good job, now let’s do the actual test. ", /// 14
        "Ready? ",
        "Go! "
    ]
    
    /// Forward Number Span Test Digits.
    let forwardNumberSpanTest = [
        "4 - 7 - 2",
        "2 - 9 - 8",
        "6 - 1 - 8 - 9",
        "5 - 3 - 8 - 7",
        "7 - 5 - 9 - 2 - 6",
        "3 - 1 - 7 - 2 - 4"
    ]
    
    /// The Backward task requires the individual to repeat numbers in the reverse order of that presented.
    let backwardsNumberSpanInstructions = [
        "Now, let’s move on to the second task. ", /// 6
        "You will hear some numbers. ",
        "Once done, you will hear a bell, like so: ",
        "(Bell Sound)", 
        "This time, you will have to repeat the numbers backwards.\n\nPlease speak slowly. Do not rush or repeat answers.",
        "For example, if you hear: ",
        "3 - 7 - 4",
        "you would say: ",
        "4 - 7 - 3",
        "If you hear: ",
        "7 – 3 – 6",
        "What would you say? ",
        
        // If the user gives the wrong answer. Skip if correct answer is given.
        "That is incorrect, you would say: ", /// 18
        "6 – 3 – 7",
        
        // If the user gives the correct answer. 
        "Good job, now let's do the actual test. ", /// 20
        "Ready? ",
        "Go! "
    ]
    
    /// Backward Number Span Test Digits. 
    let backwardsNumberSpanTest = [
        "2 - 1 - 8",
        "3 - 7 - 4",
        "7 - 4 - 1 - 5",
        "1 - 7 - 3 - 6",
        "9 - 2 - 5 - 1 - 8",
        "4 - 7 - 2 - 1 - 5"
    ]
}

