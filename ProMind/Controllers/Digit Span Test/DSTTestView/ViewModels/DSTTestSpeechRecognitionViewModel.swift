//
//  DSTTestSpeechRecognitionViewModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 24/6/22.
//

import Foundation
import SwiftUI


class DSTTestSpeechRecognitionViewModel: NSObject, ObservableObject, SFSpeechDigitNumberRecognizerDelegate {
    
    @Published var recognitionTask = RecognizationTask(expectedResult: "472")
    
    private let recognizer = SFSpeechDigitNumberRecognizer(viewModel: .DSTTestViewModel)
    private let notificationBroadcast = NotificationBroadcast()
    private let testStatistics = DSTTestStatistics()
    
    internal var viewModel: DSTViewModels
    
    static let shared = DSTTestSpeechRecognitionViewModel() // Singleton Pattern. Only allow one instance.
    
    private override init() {
        self.viewModel = .DSTTestViewModel
        super.init()
        print("DSTTestSpeechRecognitionViewModel is inited!")
        
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
        print("DSTTestSpeechRecognitionViewModel is deinited!")
    }
    
    internal func updateRecognizerLanguage(withCode language: String?) {
        if let language {
            recognizer.initializeRecognizer(withLanguageCode: language)
        }
    }
    
    internal func resetRecognizer() {
        recognizer.reset()
        recognitionTask.spokenResult = ""
    }
    
    @objc internal func startRecognitionTask(answer: String) {
        recognitionTask.expectedResult = answer
        recognitionTask.isRecording = true
        recognizer.transcribe()
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
        
        let numberOfDigits: Int = recognitionTask.expectedResult.count
        let filteredResult = transcribedReuslt.filter({ !$0.isWhitespace }) // "23 47" -> "2347"
        recognitionTask.spokenResult = filteredResult
        
        notificationBroadcast.post("Update Digit Label \(viewModel)", object: (filteredResult, numberOfDigits))
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
        
        func getNumberOfRectangles(index: Int) -> Int {
            switch index {
            case 0, 1, 23, 24:
                return 3
            case 2, 3, 25, 26:
                return 4
            case 4, 5, 27, 28:
                return 5
            default:
                print("Speech Index Error!")
                return 3
            }
        }
        
        if recognitionTask.spokenResult == recognitionTask.expectedResult {
            print("spoken result == expected result test view model")
            let roundInfo = RoundInfo.shared
            print("Speech Status Index: \(roundInfo.speechStatusIndex)")
            
            switch roundInfo.speechStatusIndex {
            case 0...4:
                roundInfo.maxDigits = roundInfo.temporaryMaxDigits
                roundInfo.currentSequence += 1
                roundInfo.didMakeWrongAnswerInPreviousRound = false
                
                testStatistics.correctAnswer(testType: .forwardSpanTest)
                Task {
                    await testStatistics.saveData(testType: .forwardSpanTest)
                }
                notificationBroadcast.post("Resume Speaking \(viewModel)", object: nil)
                notificationBroadcast.post("Stop Playing Gif \(viewModel)", object: nil)
                
            case 5:
                roundInfo.maxDigits = roundInfo.temporaryMaxDigits
                roundInfo.currentSequence += 1
                roundInfo.didMakeWrongAnswerInPreviousRound = false
                
                testStatistics.correctAnswer(testType: .forwardSpanTest)
                Task {
                    await testStatistics.saveData(testType: .forwardSpanTest)
                }
                notificationBroadcast.post("Display Backward Number Span Instructions \(viewModel)", object: nil)
                
            case 17, 19: // problem here!
                print("Submit Answer Pressed for success information! \(roundInfo.speechStatusIndex)")
                notificationBroadcast.post("Display Successful Messages \(viewModel)", object: nil)
                
            case 23...27:
                roundInfo.maxDigits = roundInfo.temporaryMaxDigits
                roundInfo.currentSequence += 1
                roundInfo.didMakeWrongAnswerInPreviousRound = false
                
                testStatistics.correctAnswer(testType: .backwardsSpanTest)
                Task {
                    await testStatistics.saveData(testType: .backwardsSpanTest)
                }
                notificationBroadcast.post("Resume Speaking \(viewModel)", object: nil)
                notificationBroadcast.post("Stop Playing Gif \(viewModel)", object: nil)
                
            case 28:
                roundInfo.maxDigits = roundInfo.temporaryMaxDigits
                roundInfo.currentSequence += 1
                roundInfo.didMakeWrongAnswerInPreviousRound = false
                
                testStatistics.correctAnswer(testType: .backwardsSpanTest)
                Task {
                    await testStatistics.saveData(testType: .backwardsSpanTest)
                }
                notificationBroadcast.post("Show Result Button \(viewModel)", object: nil)
                
            default:
                break
            }
            
        } else {
            print("spoken result != expected result test view model")
            let roundInfo = RoundInfo.shared
            
            switch roundInfo.speechStatusIndex {
            case 0...4:
                roundInfo.currentSequence = 0
                
                if roundInfo.didMakeWrongAnswerInPreviousRound { // Go to Backwards Span Test.
                    testStatistics.wrongAnswer(testType: .forwardSpanTest)
                    Task {
                        await testStatistics.saveData(testType: .forwardSpanTest)
                    }
                    
                    let numberOfRectangles = getNumberOfRectangles(index: roundInfo.speechStatusIndex)
                    notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: numberOfRectangles)
                    notificationBroadcast.post("Display Backward Number Span Instructions \(viewModel)", object: nil)
                    
                } else {
                    roundInfo.didMakeWrongAnswerInPreviousRound = true
                    testStatistics.wrongAnswer(testType: .forwardSpanTest)
                    Task {
                        await testStatistics.saveData(testType: .forwardSpanTest)
                    }
                    notificationBroadcast.post("Resume Speaking \(viewModel)", object: nil)
                    notificationBroadcast.post("Stop Playing Gif \(viewModel)", object: nil)
                }
                
            case 5:
                roundInfo.currentSequence = 0
                
                if roundInfo.didMakeWrongAnswerInPreviousRound { // Go to Backwards Span Test.
                    testStatistics.wrongAnswer(testType: .forwardSpanTest)
                    Task {
                        await testStatistics.saveData(testType: .forwardSpanTest)
                    }
                    
                    let numberOfRectangles = getNumberOfRectangles(index: roundInfo.speechStatusIndex)
                    notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: numberOfRectangles)
                    notificationBroadcast.post("Display Backward Number Span Instructions \(viewModel)", object: nil)
                    
                } else {
                    roundInfo.didMakeWrongAnswerInPreviousRound = true // Remember to set back to false when before backwards span test begins!
                    testStatistics.wrongAnswer(testType: .forwardSpanTest)
                    Task {
                        await testStatistics.saveData(testType: .forwardSpanTest)
                    }
                    notificationBroadcast.post("Display Backward Number Span Instructions \(viewModel)", object: nil)
                }
                
            case 17, 19:
                print("Submit Answer Pressed for display hint! \(roundInfo.speechStatusIndex)")
                notificationBroadcast.post("Display Hint \(viewModel)", object: nil)
                
            case 23...27:
                roundInfo.currentSequence = 0
                
                if roundInfo.didMakeWrongAnswerInPreviousRound { // Go to Result View.
                    Task {
                        await testStatistics.saveData(testType: .backwardsSpanTest)
                    }
                    
                    let numberOfRectangles = getNumberOfRectangles(index: roundInfo.speechStatusIndex)
                    notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: numberOfRectangles)
                    notificationBroadcast.post("Present Result View \(viewModel)", object: nil)
                    
                } else {
                    roundInfo.didMakeWrongAnswerInPreviousRound = true
                    testStatistics.wrongAnswer(testType: .backwardsSpanTest)
                    Task {
                        await testStatistics.saveData(testType: .backwardsSpanTest)
                    }
                    notificationBroadcast.post("Resume Speaking \(viewModel)", object: nil)
                    notificationBroadcast.post("Stop Playing Gif \(viewModel)", object: nil)
                }
                
            case 28:
                roundInfo.currentSequence = 0
                
                if roundInfo.didMakeWrongAnswerInPreviousRound { // Go to Result View.
                    Task {
                        await testStatistics.saveData(testType: .backwardsSpanTest)
                    }
                    
                    let numberOfRectangles = getNumberOfRectangles(index: roundInfo.speechStatusIndex)
                    notificationBroadcast.post("Remove Digit Rectangle \(viewModel)", object: numberOfRectangles)
                    notificationBroadcast.post("Show Result Button \(viewModel)", object: nil)
                    
                } else {
                    roundInfo.didMakeWrongAnswerInPreviousRound = true // Remember to set back to false before the view exits!
                    testStatistics.wrongAnswer(testType: .backwardsSpanTest)
                    Task {
                        await testStatistics.saveData(testType: .backwardsSpanTest)
                    }
                    notificationBroadcast.post("Show Result Button \(viewModel)", object: nil)
                }
                
            default:
                break
            }
        }
    }
    
    func availabilityDidChange() throws {
        
    }
    
    func didDetectSpeech() {
        
    }
    
    func didFinishRecognition() {
        
    }
    
    func didFinishSuccessfully() {
        
    }
}
