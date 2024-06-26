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
    @IBOutlet weak var resetButtonLabelIconImageView: UIImageView!
    @IBOutlet weak var resetButtonLabel: UILabel!
    @IBOutlet weak var submitButtonLabelIconImageView: UIImageView!
    @IBOutlet weak var submitButtonLabel: UILabel!
    @IBOutlet weak var samePageInstructionLabel1: UILabel!
    @IBOutlet weak var samePageInstructionLabel2: UILabel!
    @IBOutlet weak var samePageInstructionLabel3: UILabel!
    @IBOutlet weak var samePageInstructionLabel4: UILabel!
    @IBOutlet weak var samePageInstructionLabel5: UILabel!
    
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
        resetButtonLabel.isHidden = true
        resetButtonLabelIconImageView.isHidden = true
        submitButtonLabel.isHidden = true
        submitButtonLabelIconImageView.isHidden = true
        samePageInstructionLabel1.isHidden = true
        samePageInstructionLabel2.isHidden = true
        samePageInstructionLabel3.isHidden = true
        samePageInstructionLabel4.isHidden = true
        
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        
        speechRecognition.updateRecognizerLanguage(withCode: appLanguage.getCurrentLanguage())
        speechRecognition.resetRecognizer()
        
        UIOptimization()
        prepareStoryboardLocalization()
        
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
        // notification.addObserver(self, #selector(showUnrecognizedReminder), "Illegal Spoken Result \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideUnrecognizedReminder), "Legal Spoken Result \(mainViewModel)", object: nil)
        // notification.addObserver(self, #selector(displaySpeakingSlowlyAlert), "Display Speaking Slowly Alert \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showRecordingIndicator), "Show Recording Indicator \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideRecordingIndicator), "Hide Recording Indicator \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showPlayTutorialAgainIndicator), "Show Play Tutorial Again Indicator \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hidePlayTutorialAgainIndicator), "Hide Play Tutorial Again Indicator \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showResetButtonLabelAndIcon), "Show Reset Button Label And Icon \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideResetButtonLabelAndIcon), "Hide Reset Button Label And Icon \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showSubmitButtonLabelAndIcon), "Show Submit Button Label And Icon \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideSubmitButtonLabelAndIcon), "Hide Submit Button Label And Icon \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showSamePageInstructionLabel1), "Show Same Page Instruction Label 1 \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showSamePageInstructionLabel2), "Show Same Page Instruction Label 2 \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showSamePageInstructionLabel3), "Show Same Page Instruction Label 3 \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showSamePageInstructionLabel4), "Show Same Page Instruction Label 4 \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showSamePageInstructionLabel5), "Show Same Page Instruction Label 5 \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideSamePageInstructionLabel5), "Hide Same Page Instruction Label 5 \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideAllSamePageInstructionLabels), "Hide All Same Page Instruction Labels \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(resetInstructionLabel), "Reset Instruction Label \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideGifImage), "Hide GIF Image \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideSpokenDigitsLabel), "Hide Spoken Digits Label \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(hideResetAndSubmitButton), "Hide Reset And Submit Button \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(showInstructionLabel), "Show Instruction Label \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(enableBeginButton), "Enable Begin Button \(mainViewModel)", object: nil)
        notification.addObserver(self, #selector(disableBeginButton), "Disable Begin Button \(mainViewModel)", object: nil)
        
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
        samePageInstructionLabel1.isHidden = true
        samePageInstructionLabel2.isHidden = true
        samePageInstructionLabel3.isHidden = true
        samePageInstructionLabel4.isHidden = true
        
        /// Stop speaking, reset index to 0, and remove all notification observer.
        instructionSpeaking.speaker.synthesizer.stopSpeaking(at: .immediate)
        instructionSpeaking.resetSpeechStatus()
        speechRecognition.resetRecognizer()
        
//        coachMarksController.stop(immediately: true)
        
        notification.removeAllObserverFrom(self)
    }
    
    private func prepareStoryboardLocalization() {
        let appLanguage = UserDefaults.standard.string(forKey: "i18n_language")
        switch appLanguage {
        case "en":
            break
            
        case "ms":
            playTutorialAgainLabel.text = "Main tutorial lagi"
            recordingLabel.text = "Rakaman, sila bercakap"
            
            samePageInstructionLabel1.text = "Ingat: "
            samePageInstructionLabel2.text = "Cakap perlahan-lahan. "
            samePageInstructionLabel3.text = "Jangan tergesa-gesa ketika bercakap. "
            samePageInstructionLabel4.text = "Jangan ulangi jawapan anda. "
            samePageInstructionLabel5.text = "Klik \"Mula\" untuk memulakan ujian. "
            
            resetButtonLabel.text = "Cuba sekali lagi!"
            resetAnswerButton.setTitle("Buat Asal", for: .normal)
            
            submitButtonLabel.text = "Selesai atau tidak tahu jawapannya!"
            submitAnswerButton.setTitle("Seterusnya", for: .normal)
            
            beginButton.setTitle("Mulakan", for: .normal)
            
        case "zh-Hans":
            playTutorialAgainLabel.text = "重新观看教程"
            recordingLabel.text = "语音识别中，请说"
            
            samePageInstructionLabel1.text = "记住："
            samePageInstructionLabel2.text = "慢一点说。"
            samePageInstructionLabel3.text = "说的时候请不要抢答。"
            samePageInstructionLabel4.text = "请不要重复答案。"
            samePageInstructionLabel5.text = "点击\"开始\"按钮来开始测试。"
            
            resetButtonLabel.text = "再试一次！"
            resetAnswerButton.setTitle("重试", for: .normal)
            
            submitButtonLabel.text = "已完成或不知道答案"
            submitAnswerButton.setTitle("下一个", for: .normal)
            
            beginButton.setTitle("开始", for: .normal)
            
        default:
            break
        }
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
        spokenDigitsLabel.isHidden = true
        
        hideResetButtonLabelAndIcon()
        hideSubmitButtonLabelAndIcon()
        
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
                    spokenDigitsLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 80)
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
        print("Start recognition task - DSTMainViewController")
    }
    
    @objc private func showBeginButton() {
        avatarImageView.stopAnimatingGif()
        spokenDigitsLabel.isHidden = true
        beginButton.isHidden = false
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: { [weak self] in
            // If smaller than this value then user interaction is not working.
            self?.beginButton.alpha = 0.0100000003
        })
        // beginButton.isEnabled = true
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
    
    @objc private func showResetButtonLabelAndIcon() {
        resetButtonLabel.isHidden = false
        resetButtonLabelIconImageView.isHidden = false
    }
    
    @objc private func hideResetButtonLabelAndIcon() {
        resetButtonLabel.isHidden = true
        resetButtonLabelIconImageView.isHidden = true
    }
    
    @objc private func showSubmitButtonLabelAndIcon() {
        submitButtonLabel.isHidden = false
        submitButtonLabelIconImageView.isHidden = false
    }
    
    @objc private func hideSubmitButtonLabelAndIcon() {
        submitButtonLabel.isHidden = true
        submitButtonLabelIconImageView.isHidden = true
    }
    
    @objc private func showSamePageInstructionLabel1() {
        samePageInstructionLabel1.isHidden = false
    }
    
    @objc private func hideSamePageInstructionLabel1() {
        samePageInstructionLabel1.isHidden = true
    }
    
    @objc private func showSamePageInstructionLabel2() {
        samePageInstructionLabel2.isHidden = false
    }
    
    @objc private func hideSamePageInstructionLabel2() {
        samePageInstructionLabel2.isHidden = true
    }
    
    @objc private func showSamePageInstructionLabel3() {
        samePageInstructionLabel3.isHidden = false
    }
    
    @objc private func hideSamePageInstructionLabel3() {
        samePageInstructionLabel3.isHidden = true
    }
    
    @objc private func showSamePageInstructionLabel4() {
        samePageInstructionLabel4.isHidden = false
    }
    
    @objc private func hideSamePageInstructionLabel4() {
        samePageInstructionLabel4.isHidden = true
    }
    
    @objc private func showSamePageInstructionLabel5() {
        samePageInstructionLabel5.isHidden = false
    }
    
    @objc private func hideSamePageInstructionLabel5() {
        samePageInstructionLabel5.isHidden = true
    }
    
    @objc private func showAllSamePageInstructionLabels() {
        samePageInstructionLabel1.isHidden = false
        samePageInstructionLabel2.isHidden = false
        samePageInstructionLabel3.isHidden = false
        samePageInstructionLabel4.isHidden = false
        samePageInstructionLabel5.isHidden = false
    }
    
    @objc private func hideAllSamePageInstructionLabels() {
        samePageInstructionLabel1.isHidden = true
        samePageInstructionLabel2.isHidden = true
        samePageInstructionLabel3.isHidden = true
        samePageInstructionLabel4.isHidden = true
        samePageInstructionLabel5.isHidden = true
    }
    
    @objc private func resetInstructionLabel() {
        instructionLabel.text?.removeAll()
    }
    
    @objc private func hideGifImage() {
        avatarImageView.stopAnimatingGif()
        avatarImageView.isHidden = true
    }
    
    @objc private func hideSpokenDigitsLabel() {
        spokenDigitsLabel.isHidden = true
    }
    
    @objc private func hideResetAndSubmitButton() {
        resetAnswerButton.isHidden = true
        submitAnswerButton.isHidden = true
    }
    
    @objc private func showInstructionLabel() {
        instructionLabel.isHidden = false
    }
    
    @objc private func enableBeginButton() {
        print("Enabled begin button!")
        beginButton.isEnabled = true
    }
    
    @objc private func disableBeginButton() {
        print("Disabled begin button!")
        beginButton.isEnabled = false
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
