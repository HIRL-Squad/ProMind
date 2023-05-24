//
//  DSTTestViewController.swift
//  ProMind
//
//  Created by HAIKUO YU on 22/6/22.
//

import UIKit
import SwiftUI
import DeviceKit

class DSTTestViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var spokenDigitsLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var roundTrialLabel: UILabel!
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var trialSequenceLabel: UILabel!
    @IBOutlet weak var previousSpokenLabel: UILabel!
    @IBOutlet weak var digitSpeakingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var unrecognizedReminderLabel: UILabel!
    @IBOutlet weak var actionStack: UIStackView!
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        notificationBroadcast.post("Reset Answer Button Pressed \(testViewModel)", object: nil)
        hideUnrecognizedReminder()
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        notificationBroadcast.post("Submit Answer Button Pressed \(testViewModel)", object: nil)
    }
    
    @IBAction func beginButtonPressed(_ sender: UIButton) {
        startBackwardsSpanTest()
    }
    
    @ObservedObject var instructionSpeaking = DSTTestInstructionSpeakingViewModel.shared
    @ObservedObject var speechRecognition = DSTTestSpeechRecognitionViewModel.shared
    
    private let testViewModel = DSTViewModels.DSTTestViewModel
    private let appLanguage = AppLanguage.shared
    private let notificationBroadcast = NotificationBroadcast()
    private let timer = RepeatingTimer(tolerance: 0.1, viewModel: .DSTTestViewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        beginButton.isHidden = true
        avatarImageView.isHidden = false
        resetButton.isHidden = false
        submitButton.isHidden = false
        instructionLabel.isHidden = true
        spokenDigitsLabel.isHidden = false
        digitSpeakingActivityIndicator.isHidden = true
        resultButton.isHidden = true
        unrecognizedReminderLabel.isHidden = true
        UIOptimization()
        
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        speechRecognition.resetRecognizer()
        let roundInfo = RoundInfo.shared
        roundInfo.reset()
        
        Task {
            await removeAllExistingDigitRectangles(fromTag: 3, toTag: 5)
        }
        
        notificationBroadcast.addObserver(self, #selector(updateUILabelText(notification:)), "Instruction Text \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(playBellSound), "Play Bell Sound \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(displayUIAlert(notification:)), "Display UIAlert \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(updateDigitLabel(notification:)), "Update Digit Label \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(startRecognitionTask(notification:)), "Start Recognition Task \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(resetDigitLabel), "Reset Digit Label \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(loadGifImage), "Display Gif Image \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(showRecognizerButtons), "Show Recognizer Buttons \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(playGifImage), "Play Gif Image \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(stopPlayingGif), "Stop Playing Gif \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(showBeginButton), "Show Begin Button \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(showDigitSpeakingActivityIndicator), "Show Digit Speaking Activity Indicator \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(hideDigitSpeakingActivityIndicator), "Hide Digit Speaking Activity Indicator \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(displayBackwardNumberSpanInstructions), "Display Backward Number Span Instructions \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(presentResultView), "Present Result View \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(showResultButton), "Show Result Button \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(setDigitRectangle(notification:)), "Set Digit Rectangle \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(removeDigitRectangle(notification:)), "Remove Digit Rectangle \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(showUnrecognizedReminder), "Illegal Spoken Result \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(hideUnrecognizedReminder), "Legal Spoken Result \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(hideUnrecognizedReminder), "Hide Unrecognized Reminder \(testViewModel)", object: nil)
        notificationBroadcast.addObserver(self, #selector(displaySpeakingSlowlyAlert), "Display Speaking Slowly Alert \(testViewModel)", object: nil)
        
        try! loadGifImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        instructionSpeaking.startForwardSpanTest()
        timer.testType = .forwardSpanTest
        timer.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unrecognizedReminderLabel.isHidden = true
        
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        
        speechRecognition.updateRecognizerLanguage(withCode: appLanguage.getCurrentLanguage())
        speechRecognition.resetRecognizer()
        
        notificationBroadcast.removeAllObserverFrom(self)
        timer.end()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

/// Check device model and do optimization for iPad mini.
extension DSTTestViewController {
    
    private func UIOptimization() {
        let device = Device.current
        print("User device is \(device). ")
        
        if let deviceName = device.name {
            let deviceNameLowercased = deviceName.lowercased()
            
            switch deviceNameLowercased {
                
            /// For all iPad mini models.
            case _ where deviceNameLowercased.contains("mini") && deviceNameLowercased.contains("ipad"):
                titleLabel.font = UIFont(name: K.fontTypeMedium, size: 40)
                titleLabel.sizeToFit()
                
                let constraints = [
                    titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
                
            /// For all iPad Pro 12.9 inch models.
            case _ where deviceNameLowercased.contains("12") && deviceNameLowercased.contains("ipad"):
                let contraints = [
                    avatarImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
                    spokenDigitsLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 60)
                ]
                
                NSLayoutConstraint.activate(contraints)
                
            default:
                break
            }
        }
    }
}


// MARK: - NotificationCenter Selector Functions

/// ViewController does not allow external methods to modify internal UI elements.
/// These functions are all UI-related, and will be trigerred once notification center receives the coresponding notification from senders.

extension DSTTestViewController {
    
    @objc private func updateUILabelText(notification: Notification) {
        let instructionText = (notification.object as? String)?.localized
        instructionLabel.text = instructionText
    }
    
    @objc private func playBellSound() throws {
        do {
            try instructionSpeaking.audioPlayer.playBellSound()
        } catch let error{
            print("\(error)\nUnable to play bell sound for DSTTestView!\n")
            throw BellSoundPlayerError.audioPlayerError
        }
    }
    
    @objc private func displayUIAlert(notification: Notification) {
        let message = notification.object as? String
        let alertController = UIAlertController(title: "An error occured", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func loadGifImage() throws {
        instructionLabel.isHidden = true
        do {
            guard let gifImage = try? UIImage(gifName: "avatar_2.gif") else {
                print("Gif Image not found!\n")
                throw GifAnimationError.gifNotFound
            }
            avatarImageView.setGifImage(gifImage, loopCount: -1) /// stop at smiling face
            avatarImageView.stopAnimatingGif()
            avatarImageView.isHidden = false
        } catch {
            print("Error happens when loading the gif image!\n")
            throw GifAnimationError.errorLoadingGifImage
        }
    }
    
    @objc private func playGifImage() {
        avatarImageView.startAnimatingGif()
    }
    
    @objc private func displaySpeakingSlowlyAlert() {
        DispatchQueue.main.async {
            let message = "Please speak as slow as only one digit per second!\n\nClick Reset Answer button again, and wait for AT LEAST one second if the voice cannot be recognized!\n\nIn addition, please try to speak at least three digits before clicking Reset Answer button!".localized
            let alertController = UIAlertController(title: "Reminder".localized, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK".localized, style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    @objc private func showRecognizerButtons() {
        resetButton.isHidden = false
        submitButton.isHidden = false
        
        resetDigitLabel()
        spokenDigitsLabel.isHidden = false
    }
    
    @objc private func updateDigitLabel(notification: Notification) throws {
        guard let (spokenResult, numberOfDigits) = notification.object as? (String, Int) else {
            print("Digit Label is nil!")
            throw SFSpeechDigitNumberRecognizerError.nilDigitLabel
        }
        
        let spokenResultFilter = SpokenResultFilter(spokenResult: spokenResult, viewModel: testViewModel)
        let filteredResult = spokenResultFilter.getFilteredResult()
        
        let widthConstaint_3_digits = [spokenDigitsLabel.widthAnchor.constraint(equalToConstant: 235)]
        let widthConstaint_4_digits = [spokenDigitsLabel.widthAnchor.constraint(equalToConstant: 335)]
        let widthConstaint_5_digits = [spokenDigitsLabel.widthAnchor.constraint(equalToConstant: 435)]
        
        let digitLabelMustHaveConstraints: [NSLayoutConstraint] = [
            spokenDigitsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spokenDigitsLabel.centerXAnchor.constraint(equalTo: unrecognizedReminderLabel.centerXAnchor),
            spokenDigitsLabel.centerXAnchor.constraint(equalTo: digitSpeakingActivityIndicator.centerXAnchor),
            spokenDigitsLabel.centerYAnchor.constraint(equalTo: digitSpeakingActivityIndicator.centerYAnchor),
            spokenDigitsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            spokenDigitsLabel.heightAnchor.constraint(equalToConstant: 70)
        ]
        digitLabelMustHaveConstraints.forEach { constraint in
            constraint.priority = .required
        }
        
        let digitLabelOptionalConstraints = [
            // spokenDigitsLabel.bottomAnchor.constraint(greaterThanOrEqualTo: actionStack.topAnchor, constant: 50),
            spokenDigitsLabel.bottomAnchor.constraint(equalTo: unrecognizedReminderLabel.topAnchor, constant: 20),
            spokenDigitsLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20)
        ]
        digitLabelOptionalConstraints.forEach { constraint in
            constraint.priority = .defaultLow
        }
        
        switch numberOfDigits {
        case 3:
            NSLayoutConstraint.deactivate(spokenDigitsLabel.constraints)
            NSLayoutConstraint.activate(digitLabelMustHaveConstraints)
            NSLayoutConstraint.activate(digitLabelOptionalConstraints)
            NSLayoutConstraint.activate(widthConstaint_3_digits)
            
        case 4:
            NSLayoutConstraint.deactivate(spokenDigitsLabel.constraints)
            NSLayoutConstraint.activate(digitLabelMustHaveConstraints)
            NSLayoutConstraint.activate(digitLabelOptionalConstraints)
            NSLayoutConstraint.activate(widthConstaint_4_digits)
            
        case 5:
            NSLayoutConstraint.deactivate(spokenDigitsLabel.constraints)
            NSLayoutConstraint.activate(digitLabelMustHaveConstraints)
            NSLayoutConstraint.activate(digitLabelOptionalConstraints)
            NSLayoutConstraint.activate(widthConstaint_5_digits)
            
        default:
            print("Illegal number of digits!\n")
        }
        
        // let widthConstraint = spokenDigitsLabel.widthAnchor.constraint(equalToConstant: width)
        // widthConstraint.priority = UILayoutPriority(Float(numberOfDigits * 100))
        
        // let constraint = [widthConstraint]
            // NSLayoutConstraint.activate(constraint)
         
        // spokenDigitsLabel.sizeToFit()
        
        if filteredResult.count <= numberOfDigits {
            spokenDigitsLabel.text = filteredResult
            spokenDigitsLabel.setCharacterSpacing(by: 67)
        } else {
            let trimmedResult = String(filteredResult[..<filteredResult.indexAt(numberOfDigits)])
            spokenDigitsLabel.text = trimmedResult
            spokenDigitsLabel.setCharacterSpacing(by: 67)
        }
    }
    
    @objc private func resetDigitLabel() {
        spokenDigitsLabel.text?.removeAll()
    }
    
    @objc private func startRecognitionTask(notification: Notification) throws {
        guard let answer = notification.object as? String else {
            print("Didn't get answer string from DSTTestInstructionSpeaking ViewModel!\n")
            throw RecognitionTaskError.nilRecognitionTask
        }
        
        speechRecognition.startRecognitionTask(answer: answer)
        print("Start recognition task")
    }
    
    @objc private func stopPlayingGif() {
        avatarImageView.stopAnimatingGif()
    }
    
    @objc private func showBeginButton() {
        stopPlayingGif()
        resetButton.isHidden = true
        submitButton.isHidden = true
        spokenDigitsLabel.isHidden = true
        beginButton.isHidden = false
    }
    
    @objc private func disableResetAndSubmitButton() {
        submitButton.isEnabled = false
        resetButton.isEnabled = false
    }
    
    @objc private func enableResetAndSumbitButton() {
        submitButton.isEnabled = true
        resetButton.isEnabled = true
    }
    
    @objc private func showDigitSpeakingActivityIndicator() {
        digitSpeakingActivityIndicator.isHidden = false
        digitSpeakingActivityIndicator.startAnimating()
        
        disableResetAndSubmitButton()
    }
    
    @objc private func hideDigitSpeakingActivityIndicator() {
        digitSpeakingActivityIndicator.stopAnimating()
        digitSpeakingActivityIndicator.isHidden = true
        
        enableResetAndSumbitButton()
    }
    
    @objc private func displayBackwardNumberSpanInstructions() {
        titleLabel.text = "Backwards Number Span"
        resetButton.isHidden = true
        submitButton.isHidden = true
        avatarImageView.isHidden = true
        
        resetDigitLabel()
        spokenDigitsLabel.isHidden = true
        instructionLabel.isHidden = false
        
        timer.end()
        instructionSpeaking.speaker.synthesizer.continueSpeaking()
        instructionSpeaking.displayBackwardNumberSpanInstructions()
    }
    
    @objc private func startBackwardsSpanTest() {
        resetButton.isHidden = false
        submitButton.isHidden = false
        avatarImageView.isHidden = false
        try! loadGifImage()
        
        resetDigitLabel()
        spokenDigitsLabel.isHidden = false
        instructionLabel.isHidden = true
        beginButton.isHidden = true
        
        timer.testType = .backwardsSpanTest
        timer.start()
        
        instructionSpeaking.startBackwardSpanTest()
    }
    
    @objc private func presentResultView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "DSTResultView")
        self.present(resultViewController, animated: true)
    }
    
    @objc private func showResultButton() {
        resultButton.isHidden = false
        resetButton.isHidden = true
        submitButton.isHidden = true
    }
    
    @objc private func removeDigitRectangle(notification: Notification) throws {
        guard let tag = notification.object as? Int else {
            print("Unable to get number of digits!\n")
            throw AVSpeechFullSentenceSpeakerError.unableToGetNumberOfDigits
        }
        
        /*
        let tag = numberOfDigits
        for _ in 1...numberOfDigits {
            if let viewWithTag = view.viewWithTag(tag) {
                viewWithTag.removeFromSuperview()
            } else {
                print("Unable to find view with tag \(tag)")
            }
        }
        */
        
        Task {
            await removeDigitRectangles(withTag: tag)
        }
        
    }
    
    private func removeDigitRectangles(withTag tag: Int) async {
        let _ = Task {
            repeat {
                view.viewWithTag(tag)?.removeFromSuperview()
            } while view.viewWithTag(tag) != nil
        }
    }
    
    private func removeAllExistingDigitRectangles(fromTag lowerTag: Int, toTag higherTag: Int) async {
        let _ = Task {
            for tag in lowerTag...higherTag {
                repeat {
                    view.viewWithTag(tag)?.removeFromSuperview()
                } while view.viewWithTag(tag) != nil
            }
        }
    }
    
    @objc private func setDigitRectangle(notification: Notification) throws {
        
        guard let numberOfDigits = notification.object as? Int else {
            print("Unable to get number of digits!\n")
            throw AVSpeechFullSentenceSpeakerError.unableToGetNumberOfDigits
        }
        
        func setRectangleProperty(for spokenDigitRectangle: SpokenDigitRectangle) {
            spokenDigitRectangle.fillColor = .init(srgbRed: 0, green: 0, blue: 0, alpha: 0)
            spokenDigitRectangle.strokeColor = CGColor.init(srgbRed: 81/255, green: 77/255, blue: 229/255, alpha: 1)
            spokenDigitRectangle.lineWidth = 4
        }
        
        func display(for spokenDigitRectangle: SpokenDigitRectangle, maxX: CGFloat, maxY: CGFloat) {
            if let viewWithTag = view.viewWithTag(numberOfDigits) { // Not working.
                guard viewWithTag.accessibilityElementCount() <= numberOfDigits else {
                    return
                }
            }
            let rectangleImage = spokenDigitRectangle.makeDigitRectangle(maxX: maxX, maxY: maxY)
            let rectangleView = UIImageView(image: rectangleImage)
            rectangleView.tag = numberOfDigits // Set tag to identify which view to be removed later!
            view.addSubview(rectangleView)
        }
        
        let midX: CGFloat = spokenDigitsLabel.frame.midX
        let midY: CGFloat = spokenDigitsLabel.frame.midY
        print("midX = \(midX), midY  = \(midY), numberOfDigits = \(numberOfDigits)")
        
        if numberOfDigits % 2 == 1 { // There are odd number of rectangles.
            
            /// Generate middle rectangle with center point (midX, midY).
            let midRectangle = SpokenDigitRectangle(x: midX - 40, y: midY - 40, width: 80, height: 80)
            setRectangleProperty(for: midRectangle)
            display(for: midRectangle, maxX: view.frame.maxX, maxY: view.frame.maxY)
            
            let leftSide = (numberOfDigits - 1) / 2, rightSide = leftSide
            
            /// Generate left side rectangles with spacing 20.
            for numberOfRectangles in 1...leftSide {
                let leftSideRectangle = SpokenDigitRectangle(x: midX - 40 - CGFloat(100 * numberOfRectangles), y: midY - 40, width: 80, height: 80)
                setRectangleProperty(for: leftSideRectangle)
                display(for: leftSideRectangle, maxX: view.frame.maxX, maxY: view.frame.maxY)
            }
            
            /// Generate right side rectangles with spacing 20.
            for numberOfRectangles in 1...rightSide {
                let rightSideRectangle = SpokenDigitRectangle(x: midX - 40 + CGFloat(100 * numberOfRectangles), y: midY - 40, width: 80, height: 80)
                setRectangleProperty(for: rightSideRectangle)
                display(for: rightSideRectangle, maxX: view.frame.maxX, maxY: view.frame.maxY)
            }
            
        } else { // There are even number of rectangles.
            
            let leftSide = numberOfDigits / 2, rightSide = leftSide
            
            /// Generate left side rectangles with spacing 20.
            for numberOfRectangles in 1...leftSide {
                let leftSideRectangle = SpokenDigitRectangle(x: midX - 90 - CGFloat(100 * (numberOfRectangles - 1)), y: midY - 40, width: 80, height: 80)
                setRectangleProperty(for: leftSideRectangle)
                display(for: leftSideRectangle, maxX: view.frame.maxX, maxY: view.frame.maxY)
            }
            
            for numberOfRectangles in 1...rightSide {
                let rightSideRectangle = SpokenDigitRectangle(x: midX + 10 + CGFloat(100 * (numberOfRectangles - 1)), y: midY - 40, width: 80, height: 80)
                setRectangleProperty(for: rightSideRectangle)
                display(for: rightSideRectangle, maxX: view.frame.maxX, maxY: view.frame.maxY)
            }
        }
    }
    
    @objc private func showUnrecognizedReminder() {
        unrecognizedReminderLabel.isHidden = false
    }
    
    @objc private func hideUnrecognizedReminder() {
        unrecognizedReminderLabel.isHidden = true
    }
}
