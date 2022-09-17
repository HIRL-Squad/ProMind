//
//  DSTMainInstructionSpeakingModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 12/5/22.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

extension String {
    public func indexAt(_ indexNumber: Int) -> String.Index {
        return self.index(self.startIndex, offsetBy: indexNumber)
    }
}

struct SpeechStatus: Identifiable {
    var id = UUID()
    var index: Int
    
    /// For digit speaking such as "1 - 8 - 7", there is a pause between digits, and we should not go the the next index.
    var counter_1: Int
    var counter_2: Int
}

protocol AVAudioBellSoundPlayerDelegate {
    func audioFinishedPlaying()
}

protocol AVSpeechFullSentenceSpeakerDelegate {
    
    var viewModel: DSTViewModels { get set }
    
    func speechDidStart()
    func speechDidFinish()
}


class AVAudioBellSoundPlayer: NSObject, AVAudioPlayerDelegate {
    
    internal var audioPlayer: AVAudioPlayer?
    internal var delegate: AVAudioBellSoundPlayerDelegate!
    
    override init() {
        super.init()
        // audioPlayer?.delegate = self
        /// audioPlayer is optional, so it is nil here.
    }
    
    internal func playBellSound() throws {
        guard let path = Bundle.main.path(forResource: "Bell", ofType: "mp3") else {
            print("Audio File Path Not Found!\n")
            throw BellSoundPlayerError.audioFilePathNotFound
        }
        
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
            /// Here audioPlayer has a value.
            self.audioPlayer?.delegate = self
        } catch let error {
            print("\(error)\n")
            throw error
        }
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate.audioFinishedPlaying()
    }
}


class AVSpeechFullSentenceSpeaker: NSObject, AVSpeechSynthesizerDelegate {
    
    internal let synthesizer = AVSpeechSynthesizer()
    internal var delegate: AVSpeechFullSentenceSpeakerDelegate!
    internal var viewModel: DSTViewModels
    
    required init(viewModel: DSTViewModels) {
        self.viewModel = viewModel
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: Remember to configure speechDidFinish() in related ViewModel!
    /// Format: "1 - 8 - 7", "2 - 4 - 7 - 6", ...
    internal func speakDigits(digits: String) {
        let appLanguage = UserDefaults.standard.string(forKey: "i18n_language")
        let voice = AVSpeechSynthesisVoice(language: appLanguage)
        
        let length = digits.count
        var digitList: [Character] = []
        for index in stride(from: 0, to: length, by: 4) { // for (index = 0; index < length; index += 4).
            digitList.append(digits[digits.indexAt(index)])
        }
        
        for digit in digitList {
            let utterance = AVSpeechUtterance(string: String(digit))
            utterance.voice = voice
            utterance.rate = 0.5
            utterance.postUtteranceDelay = 0.5
            synthesizer.speak(utterance)
        }
    }
    
    internal func speakInstructions(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        let appLanguage = UserDefaults.standard.string(forKey: "i18n_language")
        let voice = AVSpeechSynthesisVoice(language: appLanguage)
        
        utterance.voice = voice
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    private func initializeAudioSession() throws {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error {
            print("\(error)\n")
            throw AVSpeechFullSentenceSpeakerError.failureCreatingAudioSession
        }
    }
    
    private func disableAudioSession() throws {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error {
            print("\(error)\n")
            throw AVSpeechFullSentenceSpeakerError.failureDisablingAudioSession
        }
    }
    
    internal func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
        print("Speaker is paused!")
    }
    
    internal func resume() {
        synthesizer.continueSpeaking()
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.delegate.speechDidFinish()
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.delegate.speechDidStart()
    }
}
