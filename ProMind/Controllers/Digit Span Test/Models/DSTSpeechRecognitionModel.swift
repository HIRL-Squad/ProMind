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
    
    required init(viewModel: DSTViewModels, language: String?) {
        self.viewModel = viewModel
        super.init()
        speechRecognizer?.delegate = self
        initializeRecognizer(withLanguageCode: appLanguage.getCurrentLanguage())
        notification.addObserver(self, #selector(updateRecognizerLanguage(notification:)), "Update System Language", object: nil)
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
        print("Did update recognizer language!")
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

//private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
//    let audioEngine = AVAudioEngine()
//    
//    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//    recognitionRequest.shouldReportPartialResults = true
//    
//    let audioSession = AVAudioSession.sharedInstance()
//    try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .duckOthers)
//    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//    let inputNode = audioEngine.inputNode
//    
//    let recordingFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)
//    
//    // Set up a file to record to.
//    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let recordingPath = path.appendingPathComponent("Digit Span Test Recording.caf")
//    
//    // Configure the
//    var settings: [String : Any] = [:]
//    settings[AVFormatIDKey] = kAudioFormatLinearPCM
//    settings[AVAudioFileTypeKey] = kAudioFileCAFType
//    settings[AVNumberOfChannelsKey] = 2
//    settings[AVLinearPCMIsNonInterleaved] = false
//      
//    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//        recognitionRequest.append(buffer)
//        
//        // Configure AVAudioPCMBuffer related properties.
//        settings[AVSampleRateKey] = buffer.format.sampleRate
//        settings[AVLinearPCMIsFloatKey] = (buffer.format.commonFormat == .pcmFormatFloat32)
//        
//        let audioFile2 = try! AVAudioFile(forWriting: recordingPath, settings: buffer.format.settings)
//        try! audioFile2.write(from: buffer)
//        
//        do {
////                let audioFile = try AVAudioFile(forWriting: recordingPath, settings: settings, commonFormat: buffer.format.commonFormat, interleaved: buffer.format.isInterleaved)
////                try audioFile.write(from: buffer)
////                print(audioFile.length)
////                print(audioFile.description)
////                print(audioFile.debugDescription)
////                print(audioFile.fileFormat)
////                print(audioFile.url)
//        } catch let error {
//            print("Error happened when writting the audio file!")
//            print(error.localizedDescription + "\n")
//        }
//    }
//    audioEngine.prepare()
//    try audioEngine.start()
//    
//    return (audioEngine, recognitionRequest)
//}
//
//internal func transcribe() {
//    DispatchQueue(label: "Speech Recognizer Queue", qos: .userInteractive).async { [weak self] in
//        guard let self = self, let recognizer = self.speechRecognizer, recognizer.isAvailable else {
//            print("Recognizer is unavailable!\n")
//            return
//        }
//        do {
//            guard let commonFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 2, interleaved: false) else {
//                print("AVAudio Format Problem!")
//                return
//            }
//            
//            // Set up a file to record to.
//            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            if #available(iOS 16.0, *) {
//                guard FileManager.default.isWritableFile(atPath: path.path()) else {
//                    print("Unable to access the document directionary!\n\n\n")
//                    return
//                }
//            } else {
//                guard FileManager.default.isWritableFile(atPath: path.path) else {
//                    print("Unable to access the document directionary!\n\n\n")
//                    return
//                }
//            }
//            
//            let recordingPath = path.appendingPathComponent("Digit Span Test Recording.wav")
//            let audioFile = try! AVAudioFile(forWriting: recordingPath, settings: commonFormat.settings, commonFormat: commonFormat.commonFormat, interleaved: false)
//            
//            // Speech Recognition + Audio Recording.
//            let (audioEngine, request) = try Self.prepareEngine()
//            
//            self.audioEngine = audioEngine
//            self.recognitionRequest = request
//            self.recognitionTask = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
//            
//            /// recognitionTask creation through delegate method is unable to work as expected.
//            // self.recognitionTask = recognizer.recognitionTask(with: request, delegate: self)
//        } catch {
//            self.reset()
//            print("Error happens for speech recognizer: \(error)")
//        }
//    }
//}
