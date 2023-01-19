//
//  TMTInstructionSpeakingModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 1/10/22.
//

import Foundation
import AVFoundation
import UIKit
import Speech

enum TMTViewModels {
    case TMTGameViewModel
}

protocol TMTInstructionSpeakingDelegate {
    var rate: Double { get set }
    var viewModel: TMTViewModels { get set }
    func speechDidStart()
    func speechDidFinish()
}

class InstructionSpeaker: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    internal var delegate: TMTInstructionSpeakingDelegate!
    
    required override init() {
        super.init()
        self.synthesizer.delegate = self
    }
    
    internal func speakInstructions(with string: String) {
        let uttrance = AVSpeechUtterance(string: string)
        let appLanguage = AppLanguage.shared.getCurrentLanguage()
        let voice = AVSpeechSynthesisVoice(language: appLanguage)
        
        uttrance.voice = voice
        uttrance.rate = 0.4
        self.synthesizer.speak(uttrance)
    }
    
    internal func pause() {
        self.synthesizer.pauseSpeaking(at: .immediate)
    }
    
    internal func resume() {
        self.synthesizer.continueSpeaking()
    }
    
    internal func stop() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.delegate.speechDidStart()
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.delegate.speechDidFinish()
    }
}

