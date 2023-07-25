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
    
    private let recognizer = SFSpeechDigitNumberRecognizer(viewModel: .DSTMainViewModel, language: AppLanguage.shared.getCurrentLanguage())
    private let notificationBroadcast = NotificationBroadcast()
    
    internal var viewModel: DSTViewModels
    
    // But app language will change from time to time. Pay attention!
    static let shared = DSTMainSpeechRecognitionViewModel() // Singleton Pattern. Only allow one instance.
    
    private override init() {
        self.viewModel = .DSTMainViewModel
        super.init()
        print("DSTMainSpeechRecognitionViewModel is inited!")
        
        self.recognizer.delegate = self
        
        notificationBroadcast.removeAllObserverFrom(self)
        notificationBroadcast.addObserver(self, #selector(updateSpokenResult(notification:)), "Transcribe Finished \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(resetAnswer), "Reset Answer Button Pressed \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(submitAnswer), "Submit Answer Button Pressed \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(pauseRecognition), "Pause Recognition \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(resumeRecognition), "Resume Recognition \(viewModel)", object: nil)
    }
    
    deinit {
        notificationBroadcast.removeAllObserverFrom(self)
        print("SpeechRecognitionViewModel is deinited!")
    }
    
    internal func resetRecognizer() {
        recognizer.reset()
        recognitionTask.spokenResult = ""
        
    }
    
    internal func updateRecognizerLanguage(withCode language: String?) {
        if let language {
            recognizer.initializeRecognizer(withLanguageCode: language)
        }
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
        let expectedResult: String = recognitionTask.expectedResult
        let filteredResult = transcribedReuslt.filter({ !$0.isWhitespace }) // "23 47" -> "2347"
        recognitionTask.spokenResult = filteredResult
        
        notificationBroadcast.post("Update Digit Label \(viewModel)", object: (filteredResult, numberOfDigits, expectedResult))
        print("Spoken result is \(recognitionTask.spokenResult).")
    }
    
    @objc private func resetAnswer() {
        recognizer.resetInput()
        recognizer.transcribe()
        recognitionTask.spokenResult = ""
        notificationBroadcast.post("Reset Digit Label \(viewModel)", object: nil)
    }
    
    @objc private func submitAnswer() {
        pauseRecognition()
        let spokenResultFilter = SpokenResultFilter(spokenResult: recognitionTask.spokenResult, expectedResult: recognitionTask.expectedResult, viewModel: .DSTMainViewModel)
        
        if recognitionTask.expectedResult == spokenResultFilter.getOptimizedResult() {
            print("spoken result == expected result - main view model")
            notificationBroadcast.post("Display Successful Messages \(viewModel)", object: nil)
            notificationBroadcast.post("Stop Playing Gif \(viewModel)", object: nil)
        } else {
            print("spoken result != expected result")
            notificationBroadcast.post("Display Hint \(viewModel)", object: nil)
            notificationBroadcast.post("Stop Playing Gif \(viewModel)", object: nil)
        }
    }
    
    
    // MARK: - delegate methods (currently not in use)
    internal func availabilityDidChange() throws {
        if let recognizer = recognizer.speechRecognizer {
            if !recognizer.isAvailable {
                notificationBroadcast.post("Display UIAlert \(viewModel)", object: "Speech recognizer is unavailable now!")
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
