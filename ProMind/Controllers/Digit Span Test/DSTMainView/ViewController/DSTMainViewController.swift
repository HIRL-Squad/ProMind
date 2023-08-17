//
//  DSTMainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/6/21.
//

import SwiftUI
import UIKit
import Foundation
import DeviceKit
import Instructions
import AVFAudio

class DSTMainViewController: UIViewController {
    
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var resetAnswerButton: UIButton!
    @IBOutlet weak var submitAnswerButton: UIButton!
    @IBOutlet weak var spokenDigitsLabel: UILabel!
    @IBOutlet weak var unrecognizedReminderLabel: UILabel!
    @IBOutlet weak var recordingIconImageView: UIImageView!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var playTutorialAgainIconImageView: UIImageView!
    @IBOutlet weak var playTutorialAgainLabel: UILabel!
    
    @IBAction func resetAnswerButtonPressed(_ sender: UIButton) {
        notification.post("Reset Answer Button Pressed \(mainViewModel)", object: nil)
        hideUnrecognizedReminder()
    }
    
    @IBAction func submitAnswerButtonPressed(_ sender: UIButton) {
        notification.post("Submit Answer Button Pressed \(mainViewModel)", object: nil)
    }
    
    /// We use singleton pattern here for those two ViewModels.
    /// If we don't use singleton pattern, every time we come back to our DSTMainView, two new instances will get created, but old instances will not be deallocated. This will result in memory leak and echo in instruction speaking when clicking on submitAnswerButton, as new observers are added but old ones are not removed!
    @ObservedObject var instructionSpeaking = DSTMainInstructionSpeakingViewModel.shared
    @ObservedObject var speechRecognition = DSTMainSpeechRecognitionViewModel.shared
    
    private let appLanguage = AppLanguage.shared
    private let notification = NotificationBroadcast()
    private let mainViewModel = DSTViewModels.DSTMainViewModel
//    private let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        coachMarksController.dataSource = self
//        coachMarksController.delegate = self
//        coachMarksController.overlay.areTouchEventsForwarded = true
//        coachMarksController.overlay.isUserInteractionEnabled = true
//        coachMarksController.overlay.backgroundColor = .clear
        
        beginButton.isHidden = true
        avatarImageView.isHidden = true
        resetAnswerButton.isHidden = true
        submitAnswerButton.isHidden = true
        instructionLabel.isHidden = false
        unrecognizedReminderLabel.isHidden = true
        recordingLabel.isHidden = true
        recordingIconImageView.isHidden = true
        playTutorialAgainLabel.isHidden = true
        playTutorialAgainIconImageView.isHidden = true
        
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        
        speechRecognition.updateRecognizerLanguage(withCode: appLanguage.getCurrentLanguage())
        speechRecognition.resetRecognizer()
        
        UIOptimization()
        
        /// Set up Notification Observer.
        notification.addObserver(self, #selector(updateUILabelText(notification:)), "Instruction Text \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(playBellSound), "Play Bell Sound \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(loadGifImage), "Display and Play Gif Image \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(displayUIAlert(notification:)), "Display UIAlert \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(updateDigitLabel(notification:)), "Update Digit Label \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(startRecognitionTask), "Start Recognition Task \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showRecognizerButtons), "Show Recognizer Buttons \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(resetDigitLabel), "Reset Digit Label \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(playGifImage), "Play Gif Image \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(stopPlayingGif), "Stop Playing Gif \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showBeginButton), "Show Begin Button \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(setDigitRectangle(notification:)), "Set Digit Rectangle \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(removeDigitRectangle(notification:)), "Remove Digit Rectangle \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showUnrecognizedReminder), "Illegal Spoken Result \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideUnrecognizedReminder), "Legal Spoken Result \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(displaySpeakingSlowlyAlert), "Display Speaking Slowly Alert \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showRecordingIndicator), "Show Recording Indicator \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideRecordingIndicator), "Hide Recording Indicator \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showPlayTutorialAgainIndicator), "Show Play Tutorial Again Indicator \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hidePlayTutorialAgainIndicator), "Hide Play Tutorial Again Indicator \(mainViewModel)", object: nil)
        
        addTapGesture(for: playTutorialAgainLabel, with: #selector(playTutorialAgainLabelTapped))
        addTapGesture(for: playTutorialAgainIconImageView, with: #selector(playTutorialAgainIconImageViewTapped))
        
        NetworkMonitor.shared.stopMonitoring()
        NetworkMonitor.shared.startMonitoring()
        
        if NetworkMonitor.shared.isConnected {
            print("Internet :: Connected!")
        } else {
            print("Internet :: Not Connected!")
            presentAlertForInternet(title: "No Internet Connection", msg: "This app needs Internet access to enable speech recognition and submit test results!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        instructionSpeaking.displayForwardNumberSpanInstructions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        beginButton.isHidden = true
        avatarImageView.isHidden = true
        resetAnswerButton.isHidden = true
        submitAnswerButton.isHidden = true
        instructionLabel.isHidden = false
        // digitSpanTestLabel.isHidden = false
        unrecognizedReminderLabel.isHidden = true
        
        /// Stop speaking, reset index to 0, and remove all notification observer.
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        speechRecognition.resetRecognizer()
        
//        coachMarksController.stop(immediately: true)
        
        notification.removeAllObserverFrom(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func restartTutorial() {
        beginButton.isHidden = true
        avatarImageView.isHidden = true
        resetAnswerButton.isHidden = true
        submitAnswerButton.isHidden = true
        instructionLabel.isHidden = false
        unrecognizedReminderLabel.isHidden = true
        recordingLabel.isHidden = true
        recordingIconImageView.isHidden = true
        
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        instructionLabel.text = "This is part of your memory and concentration task. ".localized
        
        speechRecognition.updateRecognizerLanguage(withCode: appLanguage.getCurrentLanguage())
        speechRecognition.resetRecognizer()
        
        UIOptimization()
        instructionSpeaking.displayForwardNumberSpanInstructions()
    }
    
    private func cleanUp() {
        notification.post("Remove Digit Rectangle \(mainViewModel)", object: 3)
        beginButton.isHidden = true
        avatarImageView.isHidden = true
        resetAnswerButton.isHidden = true
        submitAnswerButton.isHidden = true
        instructionLabel.isHidden = false
        // digitSpanTestLabel.isHidden = false
        unrecognizedReminderLabel.isHidden = true
        playTutorialAgainLabel.isHidden = true
        playTutorialAgainIconImageView.isHidden = true
        
        /// Stop speaking, reset index to 0, and remove all notification observer.
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        speechRecognition.resetRecognizer()
        
//        coachMarksController.stop(immediately: true)
    }
    
    private func addTapGesture(for view: UIView, with selector: Selector) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension UIStackView {
    public func removeFully(_ view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    public func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view)
        }
    }
}

// MARK: - Check device model and do optimization for iPad mini.
extension DSTMainViewController {
    
    private func UIOptimization() {
        let device = Device.current
        print("User device is \(device). ")
        
        if let deviceName = device.name {
            let deviceNameLowercased = deviceName.lowercased()
            
            switch deviceNameLowercased {
            case _ where deviceNameLowercased.contains("mini") && deviceNameLowercased.contains("ipad"):
//                digitSpanTestLabel.font = UIFont(name: K.fontTypeMedium, size: 40)
//                digitSpanTestLabel.sizeToFit()
                
//                let constraints = [
//                    digitSpanTestLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
//                ]
//                NSLayoutConstraint.activate(constraints)
                break
                
            case _ where deviceNameLowercased.contains("12") && deviceNameLowercased.contains("ipad"):
                let contraints = [
                    // avatarImageView.topAnchor.constraint(equalTo: digitSpanTestLabel.bottomAnchor, constant: 40),
                    spokenDigitsLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 60)
                ]
                
                NSLayoutConstraint.activate(contraints)
                
            default:
                break
            }
        }
    }
}

// MARK: - CoachMarkController
extension DSTMainViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    /// Defines coach mark position, much like IndexPath.
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            print("CoachMarksController returns 0!")
            return coachMarksController.helper.makeCoachMark(for: resetAnswerButton)
        case 1:
            print("CoachMarksController returns 1!")
            return coachMarksController.helper.makeCoachMark(for: submitAnswerButton)
        default:
            print("CoachMarksController returns default!")
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    /// Supplies two views in the form of a Tuple, much like cellForRowAtIndexPath.
    /// The body view is mandatory, as it's the core of the coach mark. The arrow view is optional.
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.hintLabel.font = UIFont(name: K.fontTypeNormal, size: 24)
        coachViews.bodyView.hintLabel.sizeThatFits(CGSize(width: 240, height: 50))
        
        coachViews.bodyView.nextLabel.font = UIFont(name: K.fontTypeMedium, size: 24)
        coachViews.bodyView.nextLabel.sizeThatFits(CGSize(width: 240, height: 50))
        coachViews.bodyView.nextLabel.textColor = .red
        
        //coachViews.bodyView.isUserInteractionEnabled = false
        
        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = "Try one more time!".localized
            coachViews.bodyView.nextLabel.text = "OK".localized
        case 1:
            coachViews.bodyView.hintLabel.text = "Finish or don't know answer!".localized
            coachViews.bodyView.nextLabel.text = "OK".localized
        default:
            break
        }
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}


// MARK: - NotificationCenter Selector Functions

/// ViewController does not allow external methods to modify internal UI elements.
/// These functions are all UI-related, and will be trigerred once notification center receives the coresponding notification from senders.

extension DSTMainViewController {
    
    @objc private func updateUILabelText(notification: Notification) {
        let instructionText = (notification.object as? String)?.localized
        instructionLabel.text = instructionText
    }
    
    @objc private func playBellSound() throws {
        do {
            try instructionSpeaking.playBellSound()
        } catch {
            print("Unable to play bell sound for DSTMainView!\n")
            throw BellSoundPlayerError.audioPlayerError
        }
    }
    
    @objc private func loadGifImage() throws {
        instructionLabel.isHidden = true
        do {
            guard let gifImage = try? UIImage(gifName: "avatar_2.gif") else {
                print("Gif Image not found!\n")
                throw GifAnimationError.gifNotFound
            }
            avatarImageView.setGifImage(gifImage, loopCount: -1) /// stop at smiling face
            avatarImageView.startAnimatingGif()
            avatarImageView.isHidden = false
            
        } catch {
            print("Error happens when loading the gif image!\n")
            throw GifAnimationError.errorLoadingGifImage
        }
    }
    
    @objc private func playGifImage() {
        avatarImageView.startAnimatingGif()
    }
    
    @objc private func stopPlayingGif() {
        avatarImageView.stopAnimatingGif()
    }
    
    @objc private func showRecognizerButtons() {
        resetAnswerButton.isHidden = false
        submitAnswerButton.isHidden = false
        
        resetDigitLabel()
        spokenDigitsLabel.isHidden = false
        
        /// Show coach marks together with buttons.
//        coachMarksController.start(in: .window(over: self))
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            self.coachMarksController.stop(immediately: true)
//        }
    }
    
    @objc private func displayUIAlert(notification: Notification) {
        let message = notification.object as? String
        DispatchQueue.main.async {
            let alertViewController = UIAlertController(title: "An error occured".localized, message: message, preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "OK".localized, style: .default))
            self.present(alertViewController, animated: true)
        }
    }
    
    @objc private func updateDigitLabel(notification: Notification) throws {
        guard let (spokenResult, numberOfDigits, expectedResult) = notification.object as? (String, Int, String) else {
            print("Digit Label is nil!")
            throw SFSpeechDigitNumberRecognizerError.nilDigitLabel
        }
        
        let spokenResultFilter = SpokenResultFilter(spokenResult: spokenResult, expectedResult: expectedResult, viewModel: mainViewModel)
        let filteredResult = spokenResultFilter.getTailResult()
        print("Update digit label: \(filteredResult)")
        
        let constraint = [spokenDigitsLabel.widthAnchor.constraint(equalToConstant: 236)]
        NSLayoutConstraint.activate(constraint)
        spokenDigitsLabel.sizeToFit()
        
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
    
    @objc private func displaySpeakingSlowlyAlert() {
        DispatchQueue.main.async {
            let message = "Please speak as slow as only one digit per second!\n\nClick Reset Answer button again, and wait for AT LEAST one second if the voice cannot be recognized!\n\nIn addition, please try to speak at least three digits before clicking Reset Answer button!".localized
            let alertController = UIAlertController(title: "Reminder".localized, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK".localized, style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    @objc private func startRecognitionTask() {
        speechRecognition.startRecognitionTask()
        print("Start recognition task")
    }
    
    @objc private func showBeginButton() {
        avatarImageView.stopAnimatingGif()
        resetAnswerButton.isHidden = true
        submitAnswerButton.isHidden = true
        spokenDigitsLabel.isHidden = true
        beginButton.isHidden = false
    }
    
    @objc private func setDigitRectangle(notification: Notification) throws {
        
        func setRectangleProperty(for spokenDigitRectangle: SpokenDigitRectangle) {
            spokenDigitRectangle.fillColor = .init(srgbRed: 0, green: 0, blue: 0, alpha: 0)
            spokenDigitRectangle.strokeColor = CGColor.init(srgbRed: 81/255, green: 77/255, blue: 229/255, alpha: 1)
            spokenDigitRectangle.lineWidth = 4
        }
        
        func display(for spokenDigitRectangle: SpokenDigitRectangle, maxX: CGFloat, maxY: CGFloat) {
            let rectangleImage = spokenDigitRectangle.makeDigitRectangle(maxX: maxX, maxY: maxY)
            let rectangleView = UIImageView(image: rectangleImage)
            rectangleView.tag = 3
            view.addSubview(rectangleView)
        }
        
        guard let numberOfDigits = notification.object as? Int else {
            print("Unable to get number of digits!\n")
            throw AVSpeechFullSentenceSpeakerError.unableToGetNumberOfDigits
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
    
    @objc private func removeDigitRectangle(notification: Notification) throws {
        guard let numberOfDigits = notification.object as? Int else {
            print("Unable to get number of digits!\n")
            throw AVSpeechFullSentenceSpeakerError.unableToGetNumberOfDigits
        }
        
        let tag = numberOfDigits
        for _ in 1...numberOfDigits {
            if let viewWithTag = view.viewWithTag(tag) {
                viewWithTag.removeFromSuperview()
            } else {
                print("Unable to find view with tag \(tag)")
            }
        }
    }
    
    @objc private func showUnrecognizedReminder() {
        unrecognizedReminderLabel.isHidden = false
    }
    
    @objc private func hideUnrecognizedReminder() {
        unrecognizedReminderLabel.isHidden = true
//        coachMarksController.stop(immediately: true)
    }
    
    @objc private func showRecordingIndicator() {
        recordingLabel.isHidden = false
        recordingIconImageView.isHidden = false
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .repeat], animations: { [weak self] in
            self?.recordingLabel.alpha = 0.0
            self?.recordingIconImageView.alpha = 0.0
        })
    }
    
    @objc private func hideRecordingIndicator() {
        recordingLabel.isHidden = true
        recordingIconImageView.isHidden = true
        
        recordingLabel.layer.removeAllAnimations()
        recordingLabel.alpha = 1.0
        
        recordingIconImageView.layer.removeAllAnimations()
        recordingIconImageView.alpha = 1.0
    }
    
    @objc private func showPlayTutorialAgainIndicator() {
        playTutorialAgainLabel.isHidden = false
        playTutorialAgainIconImageView.isHidden = false
    }
    
    @objc private func hidePlayTutorialAgainIndicator() {
        playTutorialAgainLabel.isHidden = true
        playTutorialAgainIconImageView.isHidden = true
    }
    
    // Add gesture recognizer for tutorial replay button.
    @objc private func playTutorialAgainIconImageViewTapped(_ sender: UIGestureRecognizer? = nil) {
        cleanUp()
        restartTutorial()
    }
    
    @objc private func playTutorialAgainLabelTapped(_ sender: UIGestureRecognizer? = nil) {
        cleanUp()
        restartTutorial()
    }
}


/// Display Alert for No Internet Access.
extension DSTMainViewController {
    
    private func presentAlertForInternet(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Open Settings".localized, style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alertController.addAction(UIAlertAction(title: "Close".localized, style: .cancel))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}


extension UILabel {
    public func setCharacterSpacing(by value: Double) {
        if let text = self.text { // There is still a chance to have "", which is not nil and has a length of 0!!!
            
            guard text.count > 0 else {
                return
            }
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: value, range: NSRange(location: 0, length: attributedString.length - 1)) // 'NSMutableRLEArray objectAtIndex:effectiveRange:: Out of bounds' may happen here with ""
            self.attributedText = attributedString
        }
    }
}
