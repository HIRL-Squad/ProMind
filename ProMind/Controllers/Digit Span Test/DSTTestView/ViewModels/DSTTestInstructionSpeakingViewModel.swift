//
//  DSTTestInstructionSpeakingViewModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 24/6/22.
//

import Foundation
import SwiftUI
import AVFAudio


class DSTTestInstructionSpeakingViewModel: NSObject, ObservableObject, AVSpeechFullSentenceSpeakerDelegate, AVAudioBellSoundPlayerDelegate {
    
    @Published var digitSpanTest = DigitSpanTest()
    @Published var speechStatus = SpeechStatus(index: 0, counter_1: 0, counter_2: 0)
    
    internal var speaker = AVSpeechFullSentenceSpeaker(viewModel: .DSTTestViewModel)
    internal let audioPlayer = AVAudioBellSoundPlayer()
    
    internal var viewModel: DSTViewModels
    private let notificationBroadcast = NotificationBroadcast()
    
    static let shared = DSTTestInstructionSpeakingViewModel() // Singleton Pattern - Only allow one instance
    
    private override init() {
        self.viewModel = .DSTTestViewModel
        super.init()
        print("DSTTestInstructionSpeakingViewModel is inited!")
        
        self.audioPlayer.delegate = self
        self.speaker.delegate = self
        
        notificationBroadcast.removeAllObserverFrom(self)
        notificationBroadcast.addObserver(self, #selector(stopSpeaking), "Stop Speaking \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(resumeSpeaking), "Resume Speaking \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(displayHint), "Display Hint \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(displaySuccessfulMessages), "Display Successful Messages \(viewModel)", object: nil)
    }
    
    deinit {
        notificationBroadcast.removeAllObserverFrom(self)
        print("DSTTestInstructionSpeakingViewModel is deinited!")
    }
    
    // MARK: Logic = SpeechDidStart -> Update UILabel -> SpeechDidFinish -> Index Increment
    
    /// Update UILabel with instruction text delivered as Notification object.
    internal func speechDidStart() {
        
        func updateRoundInfo(_ testType: DSTTestType) {
            let roundInfo = RoundInfo.shared
            
            switch testType {
            case .forwardSpanTest:
                roundInfo.testType = testType
                roundInfo.totalTrials += 1
                roundInfo.temporaryMaxDigits = 3 + speechStatus.index / 2
                
            case .backwardsSpanTest:
                roundInfo.testType = testType
                roundInfo.totalTrials += 1
                roundInfo.temporaryMaxDigits = 3 + (speechStatus.index - 23) / 2
                
            default:
                print("Unexpected found unSet for DSTTestType!\n")
            }
        }
        
        switch speechStatus.index {
        
        /// case 0 & 1: 4 7 2 -> 3 digits
        case 0:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: 3)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 2 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.forwardSpanTest)
                speechStatus.counter_2 = 0
            }
            
        case 1:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 2 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.forwardSpanTest)
                speechStatus.counter_2 = 0
            }
            
        /// case 2 & 3: 6 1 8 9 -> 4 digits
        case 2:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: 3)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: 4)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 3 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.forwardSpanTest)
                speechStatus.counter_2 = 0
            }
            
        case 3:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 3 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.forwardSpanTest)
                speechStatus.counter_2 = 0
            }
            
        /// case 4 & 5: 7 5 9 2 6 -> 5 digits
        case 4:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: 4)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: 5)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 4 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.forwardSpanTest)
                speechStatus.counter_2 = 0
            }
            
        case 5:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 4 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.forwardSpanTest)
                speechStatus.counter_2 = 0
            }
            
        case 6:
            // remove digit rectangle
            notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: 5)
            
            let instructionText = digitSpanTest.backwardsNumberSpanInstructions[speechStatus.index - 6]
            notificationBroadcast.post("Instruction Text \(viewModel)", object: instructionText)
            break
            
        /// case 23 & 24: 2 1 8 -> 3 digits
        case 23:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: 3)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 2 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.backwardsSpanTest)
                speechStatus.counter_2 = 0
            }
            
        case 24:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 2 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.backwardsSpanTest)
                speechStatus.counter_2 = 0
            }
            
        /// case 25 & 26: 7 4 1 5 -> 4 digits
        case 25:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: 3)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: 4)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 3 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.backwardsSpanTest)
                speechStatus.counter_2 = 0
            }
            
        case 26:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 3 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.backwardsSpanTest)
                speechStatus.counter_2 = 0
            }
            
        /// case 27 & 28: 9 2 5 1 8 -> 5 digits
        case 27:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: 4)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: 5)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 4 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.backwardsSpanTest)
                speechStatus.counter_2 = 0
            }
            
        case 28:
            print("speech did start with index = \(speechStatus.index)")
            notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
            notificationBroadcast.post("Show Digit Speaking Activity Indicator \(viewModel)", object: nil)
            
            if speechStatus.counter_2 < 4 {
                speechStatus.counter_2 += 1
            } else {
                updateRoundInfo(.backwardsSpanTest)
                speechStatus.counter_2 = 0
            }
            
        /// For instruction speaking.
        default:
            let instructionText = digitSpanTest.backwardsNumberSpanInstructions[speechStatus.index - 6]
            notificationBroadcast.post("Instruction Text \(viewModel)", object: instructionText)
        }
    }
    
    /// Get only numbers from instruction text like "472".
    private func getAnswerString(numberOfDigits: Int, testType: DSTTestType) -> String {
        var answer: String = ""
        
        switch testType {
        case .forwardSpanTest:
            let instructionText = digitSpanTest.forwardNumberSpanTest[speechStatus.index]
            for index in stride(from: 0, to: numberOfDigits * 4 - 3, by: 4) {
                answer.append(instructionText[instructionText.indexAt(index)])
            }
            
        case .backwardsSpanTest:
            let instructionText = digitSpanTest.backwardsNumberSpanTest[speechStatus.index - 23]
            for index in stride(from: numberOfDigits * 4 - 4, through: 0, by: -4) {
                print("Stride Through Index: \(index), digit: \(instructionText[instructionText.indexAt(index)])")
                answer.append(instructionText[instructionText.indexAt(index)])
            }
            
        default:
            break
        }
        
        return answer
    }
    
    /// Increase the instruction index after speech is finished.
    internal func speechDidFinish() {
        let roundInfo = RoundInfo.shared
        
        switch speechStatus.index {
            
        /// For digit speaking like "4 - 7 - 2", there are two pauses between digits, and we should not go the the next index.
        case 0, 1:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                let answer = getAnswerString(numberOfDigits: 3, testType: .forwardSpanTest)
                
                notificationBroadcast.post("Hide Digit Speaking Activity Indicator \(viewModel)", object: nil)
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                notificationBroadcast.post("Start Recognition Task \(viewModel)", object: answer)
                notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
                
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                speaker.pause()
            }
            
        /// "6 - 1 - 8 - 9" -> three pauses between digits.
        case 2, 3:
            if speechStatus.counter_1 < 3 {
                speechStatus.counter_1 += 1
            } else {
                let answer = getAnswerString(numberOfDigits: 4, testType: .forwardSpanTest)
                
                notificationBroadcast.post("Hide Digit Speaking Activity Indicator \(viewModel)", object: nil)
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                notificationBroadcast.post("Start Recognition Task \(viewModel)", object: answer)
                notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
                
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                speaker.pause()
            }
            
        /// "7 - 5 - 9 - 2 - 6" -> four pauses between digits.
        case 4, 5:
            if speechStatus.counter_1 < 4 {
                speechStatus.counter_1 += 1
            } else {
                let answer = getAnswerString(numberOfDigits: 5, testType: .forwardSpanTest)
                
                notificationBroadcast.post("Hide Digit Speaking Activity Indicator \(viewModel)", object: nil)
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                notificationBroadcast.post("Start Recognition Task \(viewModel)", object: answer)
                notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
                
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                speaker.pause()
            }
            
        /// For (Bell Sound), we don't want to trigger speechDidStart() to speak it out but just play a bell sound instead.
        case 8:
            roundInfo.speechStatusIndex = speechStatus.index
            
            /// Instruction to be spoken after increment: (Bell Sound)
            speechStatus.index += 1
            
            ///  Display Instruction: (Bell Sound) but do not speak it out.
            let instructionText = digitSpanTest.backwardsNumberSpanInstructions[speechStatus.index - 6].localized
            notificationBroadcast.post("Instruction Text \(viewModel)", object: instructionText)
                
            /// Play bell sound.
            notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                
            roundInfo.speechStatusIndex = speechStatus.index
            
            /// Instruction to be spoken: When you hear the bell, repeat the numbers in the same order.
            speechStatus.index += 1
            
                
        /// For digit speaking like "1 - 8 - 7", there are two pauses between digits, and we should not go the the next index.
        case 12, 16:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
            }
        
        case 14:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
            }
            
        /// Instruction finished speaking: What would you say?
        case 17:
            roundInfo.speechStatusIndex = speechStatus.index
            speechStatus.index += 1
            
            let answer = "637"
            
            notificationBroadcast.post("Display Gif Image \(viewModel)", object: nil)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: 3)
            notificationBroadcast.post("Display Speaking Slowly Alert \(viewModel)", object: nil)
            notificationBroadcast.post("Start Recognition Task \(viewModel)", object: answer)
            notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
            
        case 19:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                notificationBroadcast.post("Resume Recognition \(viewModel)", object: nil)
            }
                
        /// Do NOT increase index as 22 is the last instruction!
        case 22:
            notificationBroadcast.post("Show Begin Button \(viewModel)", object: nil)
            roundInfo.testType = .backwardsSpanTest
            roundInfo.reset()
            
        case 23, 24:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                let answer = getAnswerString(numberOfDigits: 3, testType: .backwardsSpanTest)
                print(answer)
                
                notificationBroadcast.post("Hide Digit Speaking Activity Indicator \(viewModel)", object: nil)
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                notificationBroadcast.post("Start Recognition Task \(viewModel)", object: answer)
                notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
                
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                speaker.pause()
            }
            
        case 25, 26:
            if speechStatus.counter_1 < 3 {
                speechStatus.counter_1 += 1
            } else {
                let answer = getAnswerString(numberOfDigits: 4, testType: .backwardsSpanTest)
                print(answer)
                
                notificationBroadcast.post("Hide Digit Speaking Activity Indicator \(viewModel)", object: nil)
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                notificationBroadcast.post("Start Recognition Task \(viewModel)", object: answer)
                notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
                
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                speaker.pause()
            }
            
        case 27, 28:
            if speechStatus.counter_1 < 4 {
                speechStatus.counter_1 += 1
            } else {
                let answer = getAnswerString(numberOfDigits: 5, testType: .backwardsSpanTest)
                print(answer)
                
                notificationBroadcast.post("Hide Digit Speaking Activity Indicator \(viewModel)", object: nil)
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                notificationBroadcast.post("Start Recognition Task \(viewModel)", object: answer)
                notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
                
                roundInfo.speechStatusIndex = speechStatus.index
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                speaker.pause()
            }
        
        default:
            roundInfo.speechStatusIndex = speechStatus.index
            speechStatus.index += 1
        }
    }
    
    internal func audioFinishedPlaying() {
        switch speechStatus.index {
        case 10:
            displayBackwardNumberSpanInstructions_4To11()
        default:
            break
        }
    }
    
    internal func resetSpeechStatus() {
        speechStatus.index = 0
        speechStatus.counter_1 = 0
        speechStatus.counter_2 = 0
    }
    
    @objc internal func resumeSpeaking() {
        speaker.resume()
    }
    
    @objc internal func stopSpeaking() {
        speaker.synthesizer.stopSpeaking(at: .immediate)
    }
    
    internal func startForwardSpanTest() {
        print("Start forward span test!\n")
        speechStatus.index = 0
        
        speaker = AVSpeechFullSentenceSpeaker(viewModel: .DSTTestViewModel)
        speaker.delegate = self
        
        for testDigits in digitSpanTest.forwardNumberSpanTest[0...5] {
            let localizedTestDigits = testDigits.localized
            speaker.speakDigits(digits: localizedTestDigits)
        }
    }
    
    internal func displayBackwardNumberSpanInstructions() { // start from index = 6
        print("Display backward number span instructions!\n")
        notificationBroadcast.post("Hide Unrecognized Reminder \(viewModel)", object: nil)
        speaker.synthesizer.stopSpeaking(at: .immediate)
        
        // MARK: We have to initalize a new speaker instance and assign to variable 'speaker' because synthesizer cannot start again once the utterance queue is cleared.
        // MARK: See answer from technophyle: https://stackoverflow.com/questions/19672814/an-issue-with-avspeechsynthesizer-any-workarounds?rq=1
        
        speaker = AVSpeechFullSentenceSpeaker(viewModel: .DSTTestViewModel)
        speaker.delegate = self
        
        speechStatus.index = 6
        
        for instruction in digitSpanTest.backwardsNumberSpanInstructions[0...2] {
            let localizedInstruction = instruction.localized
            speaker.speakInstructions(string: localizedInstruction)
        }
    }
    
    internal func displayBackwardNumberSpanInstructions_4To11() { // start from index = 10
        print("Display backward number span instructions 4 to 11!")
        speechStatus.index = 10
        for instruction in digitSpanTest.backwardsNumberSpanInstructions[4...11] {
            switch instruction {
            case "3 - 7 - 4", "4 - 7 - 3", "7 – 3 – 6":
                let localizedInstruction = instruction.localized
                speaker.speakDigits(digits: localizedInstruction)
            default:
                let localizedInstruction = instruction.localized
                speaker.speakInstructions(string: localizedInstruction)
            }
        }
    }
    
    internal func startBackwardSpanTest() {
        print("Start backward span test!")
        speechStatus.index = 23
        
        let roundInfo = RoundInfo.shared
        roundInfo.didMakeWrongAnswerInPreviousRound = false
        
        for testDigits in digitSpanTest.backwardsNumberSpanTest[0...5] {
            let localizedTestDigits = testDigits.localized
            speaker.speakDigits(digits: localizedTestDigits)
        }
    }
    
    @objc internal func displayHint() {
        speechStatus.index = 18
        notificationBroadcast.post("Pause Recognition \(viewModel)", object: nil)
        for instruction in digitSpanTest.backwardsNumberSpanInstructions[12...13] {
            switch instruction {
            case "6 – 3 – 7":
                let localizedInstruction = instruction.localized
                speaker.speakDigits(digits: localizedInstruction)
            default:
                let localizedInstruction = instruction.localized
                speaker.speakInstructions(string: localizedInstruction)
            }
        }
    }
    
    @objc internal func displaySuccessfulMessages() {
        speechStatus.index = 20
        notificationBroadcast.post("Pause Recognition \(viewModel)", object: nil)
        for instruction in digitSpanTest.backwardsNumberSpanInstructions[14...16] {
            let localizedInstruction = instruction.localized
            speaker.speakInstructions(string: localizedInstruction)
        }
    }
}
