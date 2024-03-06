//
//  DSTMainInstructionSpeakingViewModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 13/5/22.
//

import Foundation
import SwiftUI


class DSTMainInstructionSpeakingViewModel: NSObject, ObservableObject, AVSpeechFullSentenceSpeakerDelegate, AVAudioBellSoundPlayerDelegate {
    
    @Published var digitSpanTest = DigitSpanTest()
    @Published var speechStatus = SpeechStatus(index: 0, counter_1: 0, counter_2: 0)
    
    internal let speaker = AVSpeechFullSentenceSpeaker(viewModel: .DSTMainViewModel)
    internal let audioPlayer = AVAudioBellSoundPlayer()
    
    private let notificationBroadcast = NotificationBroadcast()
    internal var viewModel: DSTViewModels
    
    static let shared = DSTMainInstructionSpeakingViewModel() // Singleton pattern -> Only allow one instance
    
    private override init() {
        self.viewModel = .DSTMainViewModel
        super.init()
        print("DSTMainInstructionSpeakingViewModel is inited!")
        
        self.speaker.delegate = self
        self.audioPlayer.delegate = self
        
        notificationBroadcast.removeAllObserverFrom(self)
        notificationBroadcast.addObserver(self, #selector(displayHint), "Display Hint \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(displaySuccessfulMessages), "Display Successful Messages \(viewModel)", object: nil)
    }
    
    deinit {
        notificationBroadcast.removeAllObserverFrom(self)
        print("InstructionSpeakingViewModel is deinited!")
    }
    
    // MARK: Logic = SpeechDidStart -> Update UILabel -> SpeechDidFinish -> Index Increment
    
    /// Update UILabel with instruction text delivered as Notification object.
    internal func speechDidStart() {
        switch speechStatus.index {
        case 9:
            notificationBroadcast.post("Reset Instruction Label \(viewModel)", object: nil)
            notificationBroadcast.post("Show Same Page Instruction Label 1 \(viewModel)", object: nil)
            
        case 10:
            notificationBroadcast.post("Show Same Page Instruction Label 2 \(viewModel)", object: nil)
            
        case 11:
            notificationBroadcast.post("Show Same Page Instruction Label 3 \(viewModel)", object: nil)
            
        case 12:
            notificationBroadcast.post("Show Same Page Instruction Label 4 \(viewModel)", object: nil)
            
        case 13:
            notificationBroadcast.post("Hide All Same Page Instruction Labels \(viewModel)", object: nil)
            let instructionText = digitSpanTest.forwardNumberSpanInstructions[speechStatus.index]
            notificationBroadcast.post("Instruction Text \(viewModel)", object: instructionText)
            
        case 19:
            notificationBroadcast.post("Show Same Page Instruction Label 5 \(viewModel)", object: nil)
            
        default:
            let instructionText = digitSpanTest.forwardNumberSpanInstructions[speechStatus.index]
            notificationBroadcast.post("Instruction Text \(viewModel)", object: instructionText)
        }
    }
    
    /// Increase the instruction index after speech is finished.
    internal func speechDidFinish() {
        switch speechStatus.index {
            
        /// For (Bell Sound), we don't want to trigger speechDidStart() to speak it out but just play a bell sound instead.
        case 2:
            /// Instruction to be spoken after increment: (Bell Sound)
            speechStatus.index += 1
            
            ///  Display Instruction: (Bell Sound) but do not speak it out.
            let instructionText = digitSpanTest.forwardNumberSpanInstructions[speechStatus.index].localized
            notificationBroadcast.post("Instruction Text \(viewModel)", object: instructionText)
            
            /// Play bell sound.
            notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
            
            /// Instruction to be spoken: After you hear the bell, repeat the numbers in the same order...
            speechStatus.index += 1
            
        /// For digit speaking like "1 - 8 - 7", there are two pauses between digits, and we should not go the the next index.
        // 6 & 14 have the bell sound.
        case 6, 14:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                notificationBroadcast.post("Play Bell Sound \(viewModel)", object: nil)
                speechStatus.counter_1 = 0
                speechStatus.index += 1
            }
        
        // case 8 doesn't have the bell sound
        case 8:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                displayForwardNumberSpanInstructions_9To12()
            }
            
        case 12:
            speechStatus.index += 1
            displayForwardNumberSpanInstructions_13To15()
            
        case 17:
            if speechStatus.counter_1 < 2 {
                speechStatus.counter_1 += 1
            } else {
                speechStatus.counter_1 = 0
                speechStatus.index += 1
                
                notificationBroadcast.post("Resume Recognition \(viewModel)", object: nil)
                notificationBroadcast.post("Show Recording Indicator \(viewModel)", object: nil)
                notificationBroadcast.post("Show Reset Button Label And Icon \(viewModel)", object: nil)
                notificationBroadcast.post("Show Submit Button Label And Icon \(viewModel)", object: nil)
            }
            
        /// Instruction finished speaking: What would you say?
        case 15:
            speechStatus.index += 1
            
            let numberOfDigits: Int = 3
            
            notificationBroadcast.post("Display and Play Gif Image \(viewModel)", object: nil)
            notificationBroadcast.post("Set Digit Rectangle \(viewModel)", object: numberOfDigits)
            notificationBroadcast.post("Display Speaking Slowly Alert \(viewModel)", object: nil)
            notificationBroadcast.post("Show Recording Indicator \(viewModel)", object: nil)
            notificationBroadcast.post("Show Play Tutorial Again Indicator \(viewModel)", object: nil)
            notificationBroadcast.post("Show Reset Button Label And Icon \(viewModel)", object: nil)
            notificationBroadcast.post("Show Submit Button Label And Icon \(viewModel)", object: nil)
            notificationBroadcast.post("Start Recognition Task \(viewModel)", object: nil)
            notificationBroadcast.post("Show Recognizer Buttons \(viewModel)", object: nil)
        
        case 18:
            speechStatus.index += 1
            notificationBroadcast.post("Reset Instruction Label \(viewModel)", object: nil)
            notificationBroadcast.post("Disable Begin Button \(viewModel)", object: nil)
            notificationBroadcast.post("Show Begin Button \(viewModel)", object: nil)
            
        /// Do NOT increase index for the last instruction!
        case 19:
            notificationBroadcast.post("Hide Same Page Instruction Label 5 \(viewModel)", object: nil)
            notificationBroadcast.post("Enable Begin Button \(viewModel)", object: nil)
            
        default:
            speechStatus.index += 1
        }
    }
    
    internal func audioFinishedPlaying() {
        switch speechStatus.index {
        case 4:
            displayForwardNumberSpanInstructions_4To8()
        default:
            break
        }
    }
    
    internal func playBellSound() throws {
        do {
            try audioPlayer.playBellSound()
        } catch {
            print("Audio Player Error!\n")
            throw BellSoundPlayerError.audioPlayerError
        }
    }
    
    internal func resetSpeechStatus() {
        speechStatus.index = 0
        speechStatus.counter_1 = 0
        speechStatus.counter_2 = 0
    }
    
    internal func displayForwardNumberSpanInstructions() {
        speechStatus.index = 0
        for instruction in digitSpanTest.forwardNumberSpanInstructions[0...2] {
            let localizedInstruction = instruction.localized
            speaker.speakInstructions(string: localizedInstruction)
        }
    }
    
    internal func displayForwardNumberSpanInstructions_4To8() {
        speechStatus.index = 4
        for instruction in digitSpanTest.forwardNumberSpanInstructions[4...8] {
            switch instruction {
            case "1 - 8 - 7":
                let localizedInstruction = instruction.localized
                speaker.speakDigits(digits: localizedInstruction)
            default:
                let localizedInstruction = instruction.localized
                speaker.speakInstructions(string: localizedInstruction)
            }
        }
    }
    
    @objc internal func displayForwardNumberSpanInstructions_9To12() {
        speechStatus.index = 9
        for instruction in digitSpanTest.forwardNumberSpanInstructions[9...12] {
            let localizedInstruction = instruction.localized
            speaker.speakInstructions(string: localizedInstruction)
        }
    }
    
    @objc internal func displayForwardNumberSpanInstructions_13To15() {
        speechStatus.index = 13
        for instruction in digitSpanTest.forwardNumberSpanInstructions[13...15] {
            switch instruction {
            case "2 – 9 – 8":
                let localizedInstruction = instruction.localized
                speaker.speakDigits(digits: localizedInstruction)
            default:
                let localizedInstruction = instruction.localized
                speaker.speakInstructions(string: localizedInstruction)
                print("Speaking instruction: \(instruction)")
                print("Speech index = \(speechStatus.index)")
            }
        }
    }
    
    /// User may fail multiple times here, so we should reset the index.
    @objc internal func displayHint() {
        speechStatus.index = 16
        notificationBroadcast.post("Pause Recognition \(viewModel)", object: nil)
        for instruction in digitSpanTest.forwardNumberSpanInstructions[16...17] {
            switch instruction {
            case "2 – 9 – 8":
                let localizedInstruction = instruction.localized
                speaker.speakDigits(digits: localizedInstruction)
            default:
                let localizedInstruction = instruction.localized
                speaker.speakInstructions(string: localizedInstruction)
            }
        }
    }
    
    @objc internal func displaySuccessfulMessages() {
        speechStatus.index = 18
        notificationBroadcast.post("Pause Recognition \(viewModel)", object: nil)
        for instruction in digitSpanTest.forwardNumberSpanInstructions[18...19] {
            let localizedInstruction = instruction.localized
            speaker.speakInstructions(string: localizedInstruction)
        }
    }
}
