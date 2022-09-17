//
//  DSTMainSpeechRecognitionViewModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 13/5/22.
//

import Foundation
import SwiftUI


class DSTMainSpeechRecognitionViewModel: NSObject, ObservableObject, SFSpeechDigitNumberRecognizerDelegate {
    
    @Published var recognitionTask = RecognizationTask(expectedResult: "298")
    
    private let recognizer = SFSpeechDigitNumberRecognizer(viewModel: .DSTMainViewModel)
    private let notificationBroadcast = NotificationBroadcast()
    
    internal var viewModel: DSTViewModels
    
    static let shared = DSTMainSpeechRecognitionViewModel() // Singleton Pattern. Only allow one instance.
    
    private override init() {
        self.viewModel = .DSTMainViewModel
        super.init()
        print("DSTMainSpeechRecognitionViewModel is inited!")
        
        self.recognizer.delegate = self
        
        notificationBroadcast.removeAllObserverFrom(self)
        notificationBroadcast.addObserver(self, selector: #selector(updateSpokenResult(notification:)), name: "Transcribe Finished \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(resetAnswer), name: "Reset Answer Button Pressed \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(submitAnswer), name: "Submit Answer Button Pressed \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(pauseRecognition), name: "Pause Recognition \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(resumeRecognition), name: "Resume Recognition \(viewModel)", object: nil)
    }
    
    deinit {
        notificationBroadcast.removeAllObserverFrom(self)
        print("SpeechRecognitionViewModel is deinited!")
    }
    
    internal func resetRecognizer() {
        recognizer.reset()
        recognitionTask.spokenResult = ""
        
    }
    
    @objc internal func startRecognitionTask() {
        recognitionTask.isRecording = true
        recognizer.transcribe()
        
        /// Set a 30s timer.
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            print("Time out! Stop transcribing!")
            // recognizer.stopTranscribing()
            // Discuss later about what to remind the user!
        }
    }
    
    @objc internal func resumeRecognition() {
        recognitionTask.isRecording = true
        recognizer.transcribe()
    }
    
    @objc internal func pauseRecognition() {
        recognitionTask.isRecording = false
        recognizer.reset()
    }
    
    @objc private func updateSpokenResult(notification: Notification) {
        guard let transcribedReuslt = notification.object as? String else {
            print("Unexpectly found nil in transcribed result!")
            return
        }
        
        let numberOfDigits: Int = 3
        let filteredResult = transcribedReuslt.filter({ !$0.isWhitespace }) // "23 47" -> "2347"
        recognitionTask.spokenResult = filteredResult
        
        notificationBroadcast.post(name: "Update Digit Label \(viewModel)", object: (filteredResult, numberOfDigits))
        print("Spoken result is \(recognitionTask.spokenResult).")
    }
    
    @objc private func resetAnswer() {
        recognizer.resetInput()
        recognizer.transcribe()
        recognitionTask.spokenResult = ""
        notificationBroadcast.post(name: "Reset Digit Label \(viewModel)", object: nil)
    }
    
    @objc private func submitAnswer() {
        pauseRecognition()
        if recognitionTask.spokenResult == recognitionTask.expectedResult {
            print("spoken result == expected result")
            notificationBroadcast.post(name: "Display Successful Messages \(viewModel)", object: nil)
            notificationBroadcast.post(name: "Stop Playing Gif \(viewModel)", object: nil)
        } else {
            print("spoken result != expected result")
            notificationBroadcast.post(name: "Display Hint \(viewModel)", object: nil)
            notificationBroadcast.post(name: "Stop Playing Gif \(viewModel)", object: nil)
        }
    }
    
    
    // MARK: - delegate methods (currently not in use)
    internal func availabilityDidChange() throws {
        if let recognizer = recognizer.speechRecognizer {
            if !recognizer.isAvailable {
                notificationBroadcast.post(name: "Display UIAlert \(viewModel)", object: "Speech recognizer is unavailable now!")
                print("Speech recognizer is unavailable now!\n")
                throw SFSpeechDigitNumberRecognizerError.recognizerIsUnavailable
            }
        }
    }
    
    internal func didDetectSpeech() {
        print("Did Detect Speech")
    }
    
    internal func didFinishRecognition() {
        print("didFinishRecognition")
    }
    
    internal func didFinishSuccessfully() {
        print("Did Finish Successfully")
    }
}
