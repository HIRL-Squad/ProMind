//
//  DSTGameViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 17/7/21.
//

import UIKit
import AVFoundation
import Speech
import SwiftyGif

class DSTGameViewController: UIViewController {
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var digitsStackView: UIStackView! // Answer Stack View
    @IBOutlet weak var answerStackView: UIStackView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetInputButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var roundInfoLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var previousTrialInfo: UILabel!
    
    // Instructions
    private var isInstructionMode = true
    
    // Determine if it's test mode
    private var isTestMode = false
    
    // Speech Synthesis
    // private let synthesizer = AVSpeechSynthesizer()
    private var synthesizer: AVSpeechSynthesizer?

    // Speech Recognition
    private var isRecording = false
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine! // Object that controls the recording pipeline
    private var audioSession: AVAudioSession!
    
    // To keep track of the time used for each round
    private var roundTimer: Timer?
    
    // To keep track of the time used for each trial (60 seconds)
    private var trialTimeCounter = 60
    private var trialCountdownTimer: Timer?
    
    // -1: Starting Instructions; 0: Digit Forward, 1: Digit Backward, 2: Digit Sequencing
    private var numRounds = -1 {
        didSet {
            updateRoundInfoLabel()
        }
    }
    
    // Increase digits for every two trails
    private var numTrials = 1 {
        didSet {
            // Once numTrials = 12 (i.e., numDigits = 8), proceed to next round.
            if oldValue == K.DST.numDigitsMapping.count {
                numRounds += 1
                numTrials = 1
                
                instructionLabel.isHidden = false
                isInstructionMode = true
                isTestMode = false
                
                roundTimer?.invalidate()
                roundTimer = nil
            }
            
            updateRoundInfoLabel()
        }
    }
    
    private var isPreviousTrialCorrect = true

    private var currentDigits: [String] = []
    private var expectedDigits: [String] = [] // The digits that the trial is expecting
    private var spokenDigits: [String] = []
    private var spokenDigitsLabels: [UILabel] = []
    
    private var gameStatistics: [DSTGameStatistics] = [DSTGameStatistics(), DSTGameStatistics(), DSTGameStatistics()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.isHidden = true
        activityIndicatorView.startAnimating()
        
        // updateRoundInfoLabel()
        // updatePreviousTrialLabel()
        // updateStatsLabel()
        
        initSynthesizer()
        speakInstructions()
        
        // startTrial()
    }
    
    private func initSynthesizer() {
        synthesizer = AVSpeechSynthesizer()
        synthesizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermissions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dstResultViewController = segue.destination as! DSTResultViewController
        dstResultViewController.gameResultStatistics = gameStatistics
    }
    
    private func loadAvatarGif() {
        let gif = try! UIImage(gifName: "avatar_2.gif")
        avatarImageView.setGifImage(gif, loopCount: -1)
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        isInstructionMode = false
        isTestMode = true
        
        instructionLabel.isHidden = true
        startButton.isHidden = true

        // statsStackView.isHidden = false
        statsStackView.isHidden = true // Do not show stats in actual production
        digitsStackView.isHidden = false
        resetInputButton.isHidden = false
        doneButton.isHidden = false
        
        updateRoundInfoLabel()
        updatePreviousTrialLabel()
        updateStatsLabel()
        
        loadAvatarGif()
        avatarImageView.layer.borderWidth = K.borderWidth
        avatarImageView.layer.borderColor = UIColor.black.cgColor
        
        startTrial()
    }
    
    @IBAction func resetInputButtonPressed(_ sender: UIButton) {
        print("Reset pressed")
        stopRecording(isResetInput: true)
        startRecording()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        print("Done pressed")
        stopRecording(isResetInput: false)
    }
    
    private func startTrial() {
        if isTestMode {
            if roundTimer == nil {
                roundTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    self.gameStatistics[self.numRounds].totalTime += 1
                    self.updateStatsLabel()
                }
                roundTimer!.tolerance = 0.1
            }
            
            trialCountdownTimer?.invalidate()

            // Start animating avatar when the app is about to present digits
            avatarImageView.startAnimatingGif()
            initDigits()
            speakDigits()
        }
    }

    @objc func updateTrialTimeCounter() {
        if trialTimeCounter == 0 {
            print("Time's up! Sending Answers...")
            stopRecording(isResetInput: false)
        } else if trialTimeCounter > 0 {
            print("\(trialTimeCounter) seconds to the end of the trial")
            trialTimeCounter -= 1
        }
    }
    
    private func initDigits() {
        guard let numDigits = K.DST.numDigitsMapping[numTrials] else {
            handleError(withMessage: "Something wrong while retrieving number of digits")
            return
        }
        
        currentDigits = []
        
        for idx in 0..<numDigits {
            var digit = K.DST.digits.randomElement()!
            
            if idx > 0 {
                // To remove consecutive "2"
                while digit == "2" && digit == currentDigits[idx-1] {
                    digit = K.DST.digits.randomElement()!
                    print("Reshuffled number as the previous digit is \(currentDigits[idx-1]) and the current digit is also \(digit)")
                }
            }

            currentDigits.append(digit)
        }
        
        switch numRounds {
        case 0:
            expectedDigits = currentDigits
            break
        case 1:
            expectedDigits = currentDigits.reversed()
            break
        case 2:
            expectedDigits = currentDigits.sorted()
            break
        default:
            handleError(withMessage: "There was no match in numRounds")
            break
        }
    }
    
    private func checkAnswer() -> Bool {
        trialCountdownTimer?.invalidate()
        
        print("Presented Digits: \(currentDigits)")
        print("Expected Digits: \(expectedDigits)")
        print("Spoken Digits: \(spokenDigits)")
        
        if spokenDigits == expectedDigits {
            gameStatistics[numRounds].maxDigits = K.DST.numDigitsMapping[numTrials] ?? 0
            gameStatistics[numRounds].numCorrectTrials += 1
            gameStatistics[numRounds].currentSequence += 1
            gameStatistics[numRounds].longestSequence = max(gameStatistics[numRounds].currentSequence, gameStatistics[numRounds].longestSequence)
            return true
        }
        
        gameStatistics[numRounds].currentSequence = 0
        return false
    }
    
    private func resetSpokenDigits() {
        spokenDigits.removeAll()
        spokenDigitsLabels.forEach { label in
            label.removeFromSuperview()
            // answerStackView.removeArrangedSubview(label)
        }
    }
    
    private func handleError(withMessage message: String) {
        // Present an alert.
        let ac = UIAlertController(title: "An error occured", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - SpeechSynthesizer-related Functions
extension DSTGameViewController : AVSpeechSynthesizerDelegate {
    private func speakInstructions() {
        statsStackView.isHidden = true
        digitsStackView.isHidden = true
        startButton.isHidden = true
        resetInputButton.isHidden = true
        doneButton.isHidden = true
        
        let instructionText = K.DST.instructions[numRounds + 1]
        instructionLabel.text = instructionText

        print("Reading instructions for round \(numRounds + 1)...")
        
        let utterance = AVSpeechUtterance(string: instructionText)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")
        utterance.rate = K.UtteranceRate.instruction
        
        synthesizer?.speak(utterance)
        
        switch numRounds {
        case -1:
            numRounds += 1
            break
        case 0, 1, 2:
            isInstructionMode = false            
            break
        default:
            print("No matching num rounds while reading instructions...")
            break
        }
    }
    
    private func speakDigits() {
        activityIndicatorView.isHidden = true
        resetInputButton.isEnabled = false
        doneButton.isEnabled = false
        resetInputButton.backgroundColor = .lightGray
        doneButton.backgroundColor = .lightGray
//        resetInputButton.isHidden = true
//        doneButton.isHidden = true
        
        let utterance = AVSpeechUtterance(string: currentDigits.joined(separator: ","))
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")
        utterance.rate = K.UtteranceRate.digits // On average, 1 second per character. Actual rate depends on the length of the character.
        
        synthesizer?.speak(utterance)
    }
    
    // After speech synthesising is done
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isInstructionMode {
            speakInstructions()
        } else {
            if !isTestMode {
                startButton.isHidden = false
            }
        }
        
        if isTestMode {
            // Start count down after digits are presented
            trialTimeCounter = 60
            trialCountdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTrialTimeCounter), userInfo: nil, repeats: true)
            
            startRecording()
            
            activityIndicatorView.isHidden = false
            resetInputButton.isEnabled = true
            doneButton.isEnabled = true
            resetInputButton.backgroundColor = UIColor(named: "Purple")
            doneButton.backgroundColor = UIColor(named: "Purple")
//            resetInputButton.isHidden = false
//            doneButton.isHidden = false
        }
    }
}

// MARK: - SpeechRecognizer-related Functions
extension DSTGameViewController {
    private func startRecording() {
        // Load the first frame when waiting for inputs from users, so to show the smile face.
        loadAvatarGif()
        avatarImageView.stopAnimatingGif()
        
        // 1. Create a recogniser
        guard let speechRecognizer = SFSpeechRecognizer() else {
            handleError(withMessage: "Not supported for device's locale.")
            return
        }
        
        if !speechRecognizer.isAvailable {
            // Maybe no internet connection
            handleError(withMessage: "Speech recogniser not available")
            return
        }
        
        // For on-device recognition
        if speechRecognizer.supportsOnDeviceRecognition {
            print("Support on device recognition")
            recognitionRequest?.requiresOnDeviceRecognition = true
        }
                
        isRecording = true

        // 2. Create a speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            handleError(withMessage: "Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            // To capture time limit error, etc
            guard error == nil else {
                // self.handleError(withMessage: "Recognition Task:\n\(error!.localizedDescription)")
                print("Recognition Task :: Error occurred...\(error!.localizedDescription)")
                return
            }
            
            if let result = result {
                self.resetSpokenDigits()
                
                let newResult = result.bestTranscription.formattedString
                let filteredResult = newResult.filter({ !$0.isWhitespace }) // "23 47" -> "2347"
                print("New Result: \(newResult), Filtered Result: \(filteredResult), isFinal: \(result.isFinal)")
                
                filteredResult.forEach({ self.spokenDigits.append(String($0)) })
                
                DispatchQueue.main.async {
                    if self.isRecording {
                        for digit in self.spokenDigits {
                            let digitLabel = self.getLabel(labelText: digit)
                            self.spokenDigitsLabels.append(digitLabel)
                            self.answerStackView.addArrangedSubview(digitLabel)
                        }
                        
                        if result.isFinal {
                            print("result.isFinal: \(result.isFinal)")
                            self.stopRecording(isResetInput: false)
                        }
                    }
                }
            } else {
                print("Recognition Task :: No result received...")
                // self.stopRecording(isResetInput: false)
            }
        }
        
        // 3. Create a recording and classification pipeline (graphs of audio pipelines)
        audioEngine = AVAudioEngine()
        
        // Input node of the audio engine
        let inputNode = audioEngine.inputNode
        
        // bus -> channel
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Install a tap to get chunks of audio (i.e., adding a node to the graph) on the input node.
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            // Add the extracted buffers to the recognition request ready to be transcribed
            self.recognitionRequest?.append(buffer)
        }
        
        // Build the graph
        audioEngine.prepare()
        
        // 4. Start recognising speech
        do {
            // Activate the session.
            audioSession = AVAudioSession.sharedInstance()
            // try audioSession.setCategory(.record, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .mixWithOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                        
            // Start the processing pipeline
            try audioEngine.start()
        } catch {
            handleError(withMessage: "Audio Engine:\n\(error.localizedDescription)")
        }
    }
    
    private func stopRecording(isResetInput: Bool) {
        // ADDED: Cancel the previous task if it's running (isFinal will never become True...?)
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // End the recognition request.
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Stop recording
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0) // Call after audio engine is stopped as it modifies the graph.
        
        // Stop our session
        try? audioSession?.setActive(false)
        audioSession = nil
        
        print("isResetInput: \(isResetInput)")
        
        if isResetInput {
            resetSpokenDigits()
        } else {            
            isRecording = false
            
            let isAnswerCorrect = checkAnswer()
            updateStatsLabel()
            
            if isAnswerCorrect {
                isPreviousTrialCorrect = true // Current Trial is correct (but will be interpreted as the previous trial)
            } else {
                
                // If both previous and current trials are incorrect, then skip to next round
                if !isPreviousTrialCorrect {
                    isPreviousTrialCorrect = true
                    numRounds += 1
                    numTrials = 0 // Upon exitting from this function, numTrials will be incremented immediately
                    
                    instructionLabel.isHidden = false
                    isInstructionMode = true
                    isTestMode = false
                    
                    roundTimer?.invalidate()
                    roundTimer = nil
                } else {
                    isPreviousTrialCorrect = false
                }
            }
            
            numTrials += 1
            updatePreviousTrialLabel()
            
            resetSpokenDigits()
            activityIndicatorView.isHidden = true
            
            // End of Match
            if numRounds > 2 {
                roundTimer?.invalidate()
                self.performSegue(withIdentifier: K.DST.goToDSTResultSegue, sender: self)
            } else {
                if isTestMode {
                    startTrial()
                    return
                }
                
                if isInstructionMode {
                    speakInstructions()
                    return
                }
            }
        }
    }
}

// MARK: - Label-related Functions
extension DSTGameViewController {
    private func getLabel(labelText digit: String) -> UILabel {
        let digitLabel = UILabel()
        digitLabel.text = digit
        digitLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 60)
        
        return digitLabel
    }
    
    private func updateRoundInfoLabel() {
        let roundInfoText = NSMutableAttributedString.init()
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]
        
        let numRoundsText = NSMutableAttributedString(string: "Round: ", attributes: attrs)
        numRoundsText.append(NSMutableAttributedString(string: "\(numRounds + 1)\n"))
        
        let numTrialsText = NSMutableAttributedString(string: "Trial: ", attributes: attrs)
        numTrialsText.append(NSMutableAttributedString(string: "\(numTrials)"))
        
        roundInfoText.append(numRoundsText)
        roundInfoText.append(numTrialsText)
        
        roundInfoLabel.isHidden = false
        roundInfoLabel.attributedText = roundInfoText
    }
    
    private func updatePreviousTrialLabel() {
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]
        let previousTrialInfoText = NSMutableAttributedString(string: "Previous Trials\n", attributes: attrs)
        
        let previousDigitsText = NSMutableAttributedString(string: "Digits: ", attributes: attrs)
        let previousSpokenDigitsText = NSMutableAttributedString(string: "Spoken Digits: ", attributes: attrs)
        if numTrials == 1 {
            previousDigitsText.append(NSMutableAttributedString(string: "-\n"))
            previousSpokenDigitsText.append(NSMutableAttributedString(string: "-"))
        } else {
            previousDigitsText.append(NSMutableAttributedString(string: "\(currentDigits.joined(separator: " "))\n"))
            previousSpokenDigitsText.append(NSMutableAttributedString(string: "\(spokenDigits.joined(separator: " "))"))
        }
        
        previousTrialInfoText.append(previousDigitsText)
        previousTrialInfoText.append(previousSpokenDigitsText)
        
        previousTrialInfo.isHidden = false
        previousTrialInfo.attributedText = previousTrialInfoText
    }
    
    private func updateStatsLabel() {
        statsLabel.isHidden = false
        statsLabel.attributedText = gameStatistics[numRounds].getFormattedGameStats()
    }
}

// MARK: - Permissions-related Control
extension DSTGameViewController {
    private func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    // Good to go
                    print("Authorised!")
                    break
                case .denied:
                    // User said no
                    print("Denied!")
                    self.handlePermissionFailed(msg: "Denied")
                    break
                case .restricted:
                    // Device isn't permitted
                    print("Restricted!")
                    self.handlePermissionFailed(msg: "Restricted")
                    break
                case .notDetermined:
                    // Don't know yet
                    print("Not Determined!")
                    self.handlePermissionFailed(msg: "Not Determined")
                    break
                default:
                    print("Something went wrong while requesting authorisation for speech recognition!")
                    self.handlePermissionFailed(msg: "Unknown")
                }
            }
        }
    }
    
    private func handlePermissionFailed(msg: String) {
        // Present an alert asking the user to change their settings.
        let ac = UIAlertController(title: "This app must have access to speech recognition to work.",
                                   message: "Code: \(msg)! Please consider updating your settings.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Open settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        ac.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(ac, animated: true)
    }
}
