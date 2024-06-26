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
        "After you hear the bell, repeat the numbers in the same order. ", /// 4
        "For example, if you hear: ",
        "1 - 8 - 7",
        "You would say: ",
        "1 - 8 - 7",
        "Remember: ", /// 9
        "Speak slowly. ",
        "Do not rush when speaking. ",
        "Do not repeat your answers. ",
        "If you hear: ", /// 13
        "2 – 9 – 8",
        "What would you say? ",
        
        // If the user gives the wrong answer. Skip if correct answer is given.
        "That is incorrect, you would say: ", /// 16
        "2 – 9 – 8",
        
        // If the user gives the correct answer.
        "Great! We are going to the actual test! ", /// 18
        "Click \"Start\" to begin the test. "
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
        "Now, let’s move on to the second task. ", /// 6 - 0
        "You will hear some numbers. ",
        "Once done, you will hear a bell, like so: ",
        "(Bell Sound)", 
        "This time, you will have to repeat the numbers backwards. ", /// 10 - 4
        "For example, if you hear: ",
        "3 - 7 - 4",
        "you would say: ",
        "4 - 7 - 3",
        "Remember: ", /// 15 - 9
        "Speak slowly. ",
        "Do not rush when speaking. ",
        "Do not repeat your answers. ",
        "If you hear: ", /// 19 - 13
        "7 – 3 – 6",
        "What would you say? ",
        
        // If the user gives the wrong answer. Skip if correct answer is given.
        "That is incorrect, you would say: ", /// 22 - 16
        "6 – 3 – 7",
        
        // If the user gives the correct answer. 
        "Great! We are going to the actual test! ", /// 24 - 18
        "Click \"Start\" to begin the test. "
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

