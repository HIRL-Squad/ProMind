//
//  DSTMainSpeechRecognitionModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 18/5/22.
//

import Foundation
import SwiftUI
import Speech

enum GifAnimationStatus {
    case willLoad
    case didLoad
    case didStartAnimating
    case didFinishAnimating
}

enum DSTViewModels {
    case DSTMainViewModel
    case DSTTestViewModel
}

struct GifAnimation: Identifiable {
    var id = UUID()
    var status: GifAnimationStatus
}

struct RecognizationTask: Identifiable {
    var id = UUID()
    var isRecording: Bool = false
    var spokenResult: String = ""
    var expectedResult: String
}

protocol SFSpeechDigitNumberRecognizerDelegate {
    
    var viewModel: DSTViewModels { get set }
    
    func availabilityDidChange() throws 
    func didDetectSpeech()
    func didFinishRecognition()
    func didFinishSuccessfully()
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}

class SFSpeechDigitNumberRecognizer: NSObject, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
    
    internal var speechRecognizer: SFSpeechRecognizer?
    internal var finalResult: String = ""
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine? // Object that controls the recording pipeline
    private var audioSession: AVAudioSession?
    
    internal var delegate: SFSpeechDigitNumberRecognizerDelegate!
    internal var viewModel: DSTViewModels
    
    private let notification = NotificationBroadcast()
    private let appLanguage = AppLanguage.shared
    
    required init(viewModel: DSTViewModels) {
        self.viewModel = viewModel
        super.init()
        speechRecognizer?.delegate = self
        initializeRecognizer(withLanguageCode: appLanguage.getCurrentLanguage())
        notification.addObserver(self, #selector(updateRecognizerLanguage(notification:)), "Update Recognizer Language \(viewModel)", object: nil)
    }
    
    internal func initializeRecognizer(withLanguageCode language: String?) {
        if let language {
            speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: language))
        } else {
            speechRecognizer = SFSpeechRecognizer()
            print("Unable to retrieve app language from i18n_language!")
        }
        
        Task(priority: .background) {
            do {
                guard speechRecognizer != nil else {
                    notification.post("Display UIAlert \(viewModel)", object: "Not supported for device's locale.")
                    print("Nil recognizer!\n")
                    throw SFSpeechDigitNumberRecognizerError.nilRecognizer
                }
                                
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    notification.post("Display UIAlert \(viewModel)", object: "Not authorized to recognize!")
                    print("Not authorized to recognize!\n")
                    throw SFSpeechDigitNumberRecognizerError.notAuthorizedToRecognize
                }
                
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    notification.post("Display UIAlert \(viewModel)", object: "Speech recognizer requires permission to work!")
                    print("Not permitted to record!\n")
                    throw SFSpeechDigitNumberRecognizerError.notPermittedToRecord
                }
            } catch {
                print("Error happens when initializing speech recognizer: \(error)\n")
                throw error
            }
        }
    }
    
    @objc internal func updateRecognizerLanguage(notification: Notification) throws {
        guard let language = notification.object as? String else {
            print("Illegal application language received when updating recognizer!")
            throw SFSpeechDigitNumberRecognizerError.illegalApplicationLanguageReceived
        }
        initializeRecognizer(withLanguageCode: language)
    }
    
    deinit {
        reset()
    }
    
    internal func transcribe() {
        DispatchQueue(label: "Speech Recognizer Queue", qos: .userInteractive).async { [weak self] in
            guard let self = self, let recognizer = self.speechRecognizer, recognizer.isAvailable else {
                print("Recognizer is unavailable!\n")
                return
            }
            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.recognitionRequest = request
                self.recognitionTask = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
                
                /// recognitionTask creation through delegate method is unable to work as expected.
                // self.recognitionTask = recognizer.recognitionTask(with: request, delegate: self)
            } catch {
                self.reset()
                print("Error happens for speech recognizer: \(error)")
            }
        }
    }
    
    internal func stopTranscribing() {
        reset()
    }
    
    internal func reset() {
        recognitionTask?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    internal func resetInput() {
        reset()
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, recognitionRequest)
    }
    
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
        }
        
        if let result = result {
            finalResult = result.bestTranscription.formattedString
            notification.post("Play Gif Image \(viewModel)", object: nil)
            notification.post("Transcribe Finished \(viewModel)", object: finalResult)
        }
    }
    
    /// Deprecated delegate methods.
    private func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) throws {
        try self.delegate.availabilityDidChange()
    }
    
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        self.delegate.didDetectSpeech()
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        self.delegate.didFinishRecognition()
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        self.delegate.didFinishSuccessfully()
    }
}


