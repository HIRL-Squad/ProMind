//
//  TMTTutorialViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 17/9/21.
//

import UIKit
import Speech

class TMTGameViewController: UIViewController {
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var actionButtonsStackView: UIStackView!
    
    // Speech Synthesis
    private var synthesizer: AVSpeechSynthesizer?
    private var instructionState = 0
    
    private var isFirstChangeInSubview = true // To handle the subview change upon first loading
        
    // ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25"]
    // ["1","A","2","B","3","C","4","D","5","E","6","F","7","G","8","H","9","I","10","J","11","K","12","L","13"]
    var currentLabels: [String] = []
    
    // Line Drawing
    var currentUIViewForCircles = UIView()
    var lineImageView = UIImageView() // old: myImageView - to render lines drawn
    var lastScreenshot = UIImage()
    
    var isTutorial = true
    var canTouch = false // Only used in Tutorial. Always true for Test.
    var canDraw = false
    var firstPoint: CGPoint?
    var secondPoint: CGPoint?
    
    // For Tutorial use
    var tutViewWidth: CGFloat = 0.0
    var tutViewHeight: CGFloat = 0.0
    var tutCircleCenterPoints: [CGPoint] = []
    var tutCircleViews: [UIView] = []
    var currentCircleIndex = 0
    
    // For Test use
    var testViewWidth: CGFloat = 0.0
    var testViewHeight: CGFloat = 0.0
    var testCircleCenterPoints: [CGPoint] = []
    var testCircleViews: [UIView] = []
    
    var numRound = 0
    var timer = Timer()
    var timeLeft: Int = 0 {
        didSet {
            let timerText = NSMutableAttributedString(string: "Time Left: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
            timerText.append(NSMutableAttributedString(string: "\(timeLeft) s"))
            timerLabel.attributedText = timerText
            
            timerLabel.isHidden = false
        }
    }
    var isTimerPlaying = false
    var gameStatistics: [TMTGameStatistics] = [TMTGameStatistics(), TMTGameStatistics()]
    
    private func updateStatsLabel() {
        statsLabel.isHidden = false
        statsLabel.attributedText = gameStatistics[numRound].getFormattedGameStats()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.bottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Width: \(view.frame.width)")
        print("Height: \(view.frame.height)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIGestureRecognizer().allowedTouchTypes = [UITouch.TouchType.pencil.rawValue, UITouch.TouchType.direct.rawValue] as [NSNumber]
        navigationController?.isNavigationBarHidden = false
        // initTest()
    }
    
    override func viewDidLayoutSubviews() {
        if isFirstChangeInSubview {
            isFirstChangeInSubview = false
            print("tutorialView.bounds.width: \(self.tutorialView.bounds.width)")
            print("tutorialView.bounds.height: \(self.tutorialView.bounds.height)")
            self.initTutorial(state: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        synthesizer?.stopSpeaking(at: .immediate)
        synthesizer = nil
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setInstructionLabelText(message: String) {
        instructionLabel.text = message
    }
    
    private func getNumCircles() -> Int {
        // return isTutorial ? K.TMT.tutNumCircles : TMTResultViewController.numCircles
        if isTutorial {
            return 10
        } else {
            return 15
        }
    }
    
    private func getTotalTime() -> Int {
        return K.TMT.numCirclesTimeMapping[getNumCircles()]!
    }
    
    private func initTutorial(state: Int) {
        navigationController?.isNavigationBarHidden = false
        
        instructionLabel.isHidden = false
        tutorialView.isHidden = false
        
        
        
        currentUIViewForCircles = tutorialView
        tutCircleViews = removeCirclesFromView(circleViews: tutCircleViews)
        testCircleViews = removeCirclesFromView(circleViews: testCircleViews)
        displayLastScreenshot(reset: true, displayView: tutorialView)
        displayLastScreenshot(reset: true, displayView: view)
        
        tutViewWidth = tutorialView.bounds.width
        tutViewHeight = tutorialView.bounds.height
        
        tutorialView.layer.borderWidth = K.borderWidth
        tutorialView.layer.borderColor = UIColor(named: "Purple")?.cgColor
        
        tutCircleCenterPoints = [
            CGPoint(x: tutViewWidth[12], y: tutViewHeight[17]),
            CGPoint(x: tutViewWidth[23], y: tutViewHeight[53]),
            CGPoint(x: tutViewWidth[48], y: tutViewHeight[72]),
            CGPoint(x: tutViewWidth[72], y: tutViewHeight[48]),
            CGPoint(x: tutViewWidth[87], y: tutViewHeight[14]),
            CGPoint(x: tutViewWidth[17], y: tutViewHeight[78]),
            CGPoint(x: tutViewWidth[47], y: tutViewHeight[51]),
            CGPoint(x: tutViewWidth[42], y: tutViewHeight[20]),
            CGPoint(x: tutViewWidth[67], y: tutViewHeight[83]),
            CGPoint(x: tutViewWidth[92], y: tutViewHeight[66]),
        ]
        
        currentLabels = K.TMT.labels[numRound] // Start with Round 0
        
        instructionState = state
        instructionLabel.text = ""
        currentCircleIndex = 0
        
        isTutorial = true
        canTouch = false
        canDraw = false
        
        actionButtonsStackView.isHidden = true
        statsStackView.isHidden = true
        
        createNewTutCircles()
        
        initSynthesizer()
        speakInstructions()
    }
    
    private func initTest() {
        UIGestureRecognizer().allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
        // navigationController?.isNavigationBarHidden = true
        
        instructionLabel.isHidden = true
        tutorialView.isHidden = true
        
        currentUIViewForCircles = view
        tutCircleViews = removeCirclesFromView(circleViews: tutCircleViews)
        testCircleViews = removeCirclesFromView(circleViews: testCircleViews)
        displayLastScreenshot(reset: true, displayView: tutorialView)
        displayLastScreenshot(reset: true, displayView: view)
        
        testViewWidth = view.bounds.width - 50
        testViewHeight = view.bounds.height - 50
        
        testCircleCenterPoints = [
            CGPoint(x: testViewWidth[10], y: testViewHeight[17]),
            CGPoint(x: testViewWidth[10], y: testViewHeight[50]),
            CGPoint(x: testViewWidth[10], y: testViewHeight[83]),
            
            CGPoint(x: testViewWidth[30], y: testViewHeight[17]),
            CGPoint(x: testViewWidth[30], y: testViewHeight[50]),
            CGPoint(x: testViewWidth[30], y: testViewHeight[83]),
            
            CGPoint(x: testViewWidth[50], y: testViewHeight[17]),
            CGPoint(x: testViewWidth[50], y: testViewHeight[50]),
            CGPoint(x: testViewWidth[50], y: testViewHeight[83]),
            
            CGPoint(x: testViewWidth[70], y: testViewHeight[17]),
            CGPoint(x: testViewWidth[70], y: testViewHeight[50]),
            CGPoint(x: testViewWidth[70], y: testViewHeight[83]),
            
            CGPoint(x: testViewWidth[90], y: testViewHeight[17]),
            CGPoint(x: testViewWidth[90], y: testViewHeight[50]),
            CGPoint(x: testViewWidth[90], y: testViewHeight[83]),
        ]
        
        currentLabels = K.TMT.labels[numRound] // Start with Round 0
        stopTimer()

        currentCircleIndex = 0
        
        isTutorial = false
        canTouch = true
        canDraw = false
        
        actionButtonsStackView.isHidden = true
        statsStackView.isHidden = true // Do not show stats in production
        
        gameStatistics[numRound].numCirclesLeft = getNumCircles()
        gameStatistics[numRound].numErrors = 0
        gameStatistics[numRound].numLifts = 0
        updateStatsLabel()
        
        createNewTestCircles()
        startTimer()
    }
    
    private func startTimer(){
        timeLeft = getTotalTime()
        isTimerPlaying = true
    }

    private func stopTimer(){
        isTimerPlaying = false
    }
    
    @objc func updateTimer(){
        if isTimerPlaying {
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                gameStatistics[numRound].totalTimeTaken = getTotalTime() + 1

                stopTimer()
                canDraw = false

                for circle in testCircleViews {
                    // Unattempted circles will be shown as Red
                    if circle.backgroundColor == .lightGray {
                        circle.backgroundColor = .red
                    }
                }

                endSubTest()
            }
        }
    }
    
    private func endSubTest() {
        if numRound == 0 {
            // Enter TMT-B
            // Start Tutorial for TMT-B
            numRound = 1
            currentLabels = K.TMT.labels[numRound]

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.initTutorial(state: 0)
            }
        } else {
            // End Game
            // Present scores
            self.performSegue(withIdentifier: K.TMT.goToTMTResultSegue, sender: self)
        }
    }
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        initTutorial(state: 2)
    }
    
    @IBAction func beginButtonPressed(_ sender: UIButton) {
        if isTutorial {
            isTutorial = false
            
            navigationController?.isNavigationBarHidden = true
            actionButtonsStackView.isHidden = true
            displayLastScreenshot(reset: true, displayView: tutorialView) // Reset display from Tutorial
            for circleView in tutCircleViews {
                circleView.backgroundColor = .lightGray
            }
            tutorialView.isHidden = true
            let instruction = ["There are a total of \(getNumCircles()) circles.",
                               "Please connect them without lifting the stylus as much as possible.",
                               "You have \(getTotalTime()) seconds."]
            
            let text = "There are a total of \(getNumCircles()) circles.\nPlease connect them without lifting the stylus as much as possible.\nYou have \(getTotalTime()) seconds.".localized
            setInstructionLabelText(message: text)
            speak(text: text, preUtteranceDelay: 0.5)
            
            // Init Test is performed in didFinish(:) after speech is done.
        }
    }
    
    private func createCircleView(idx: Int, width: CGFloat, height: CGFloat, centerX: CGFloat, centerY: CGFloat) -> UIView {
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: width[8], height: width[8])) // Set width = height to create a circular view
        circleView.center = CGPoint(x: centerX, y: centerY)
        circleView.backgroundColor = .lightGray
        circleView.layer.cornerRadius = width[4] // Same as "circleView.frame.size.width / 2"
        circleView.layer.borderWidth = width[0.20]
        circleView.layer.borderColor = UIColor.black.cgColor
        circleView.tag = idx

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width[8], height: width[8]))
        label.text = currentLabels[idx]
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.adjustsFontForContentSizeCategory = true
        
        circleView.addSubview(label)
        
        return circleView
    }
    
    private func removeCirclesFromView(circleViews: [UIView]) -> [UIView] {
        for circleView in circleViews {
            circleView.removeFromSuperview()
        }
        return []
    }
    
    private func createNewTutCircles() {
        tutCircleViews = removeCirclesFromView(circleViews: tutCircleViews)
        
        for idx in 0...getNumCircles() - 1 {
            let tutCircleView = createCircleView(
                idx: idx,
                width: tutViewWidth,
                height: tutViewHeight,
                centerX: tutCircleCenterPoints[idx].x,
                centerY: tutCircleCenterPoints[idx].y
            )
            tutorialView.addSubview(tutCircleView)
            tutCircleViews.append(tutCircleView)
        }
    }
    
    private func createNewTestCircles() {
        testCircleViews = removeCirclesFromView(circleViews: testCircleViews)
        testCircleCenterPoints.shuffle()
        
        // Mark the begin point as cyan
        let beginCircleView = createCircleView(
            idx: 0,
            width: testViewWidth,
            height: testViewHeight,
            centerX: testCircleCenterPoints[0].x + CGFloat(Int.random(in: -20..<40)),
            centerY: testCircleCenterPoints[0].y + CGFloat(Int.random(in: -20..<40))
        )
        hightlightCircle(view: beginCircleView, color: .cyan, delay: nil)
        view.addSubview(beginCircleView)
        testCircleViews.append(beginCircleView)
        
        for idx in 1..<getNumCircles() - 1 {
            let testCircleView = createCircleView(
                idx: idx,
                width: testViewWidth,
                height: testViewHeight,
                centerX: testCircleCenterPoints[idx].x + CGFloat(Int.random(in: -20..<40)),
                centerY: testCircleCenterPoints[idx].y + CGFloat(Int.random(in: -20..<40))
            )
            view.addSubview(testCircleView)
            testCircleViews.append(testCircleView)
        }
        
        // Mark the end point as cyan
        let endCircleView = createCircleView(
            idx: getNumCircles() - 1,
            width: testViewWidth,
            height: testViewHeight,
            centerX: testCircleCenterPoints[getNumCircles() - 1].x + CGFloat(Int.random(in: -20..<40)),
            centerY: testCircleCenterPoints[getNumCircles() - 1].y + CGFloat(Int.random(in: -20..<40))
        )
        hightlightCircle(view: endCircleView, color: .cyan, delay: nil)
        view.addSubview(endCircleView)
        testCircleViews.append(endCircleView)
    }
    
    private func displayLastScreenshot(reset: Bool, displayView: UIView) {
        // If it is meant to reset the whole screen, remove all the lines.
        if reset {
            lastScreenshot = UIImage()
        }
        
        // To reinitialise lineImageView, and set the image to be the last drawn lines. Useful to remove errornous lines.
        lineImageView.removeFromSuperview() // To remove the current lineImageView from the tutorialView first.
        lineImageView = UIImageView(frame: displayView.bounds)
        lineImageView.backgroundColor = .white
        lineImageView.image = lastScreenshot
        lineImageView.layer.zPosition = -1
        currentUIViewForCircles.addSubview(lineImageView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tmtResultViewController = segue.destination as! TMTResultViewController
        tmtResultViewController.gameResultStatistics = gameStatistics
    }
}

// MARK: - SpeechSynthesizer-related Functions
extension TMTGameViewController: AVSpeechSynthesizerDelegate {
    private func initSynthesizer() {
        synthesizer = AVSpeechSynthesizer()
        synthesizer?.delegate = self
    }
    
    private func speakInstructions() {
        print("numRound: \(numRound)")
        print("instructionState: \(instructionState)")
        
        var prefersHomeIndicatorAutoHidden: Bool {
            return true
        }
        
        let instructions = K.TMT.instructions[numRound]
        
        if instructionState == instructions.count || !isTutorial {
            return
        }
        
        // let instructionString = instructions[instructionState]
        
        // let instruction = NSLocalizedString(instructionString, comment: "Localize TMT & DST Instructions")
        
        // To get instructions for either test A or B. Set instruction to NSLocalizedString.
        let instruction = instructions[instructionState].localized
        
        setInstructionLabelText(message: instruction)

        switch instructionState {
        case 0, 7, 8:
            speak(text: instruction, preUtteranceDelay: 0.5)
            
        case 1:
            speak(text: instruction, preUtteranceDelay: 1.0)
            flashAllCircles(delay: 1.0)
            
        /// Begin at number 1
        case 2:
            speak(text: instruction, preUtteranceDelay: 1.0)
            flash(view: tutCircleViews[currentCircleIndex], preBackgroundColour: .cyan, delay: 1.0)
            
        /// draw a line in ascending order from 1 to 2
        case 3:
            speak(text: instruction, preUtteranceDelay: 1.0)
            flash(view: tutCircleViews[currentCircleIndex], preBackgroundColour: .cyan, delay: 1.0)
            flash(view: tutCircleViews[currentCircleIndex + 1], preBackgroundColour: .yellow, delay: 1.0)
            
            let animation = DrawingAnimation(duration: 3)
            drawLines(idx1: currentCircleIndex, idx2: currentCircleIndex + 1, color1: .cyan, color2: .green, drawingAnimation: animation)
            
        /// 2 to 3, 3 to 4
        case 4, 5:
            speak(text: instruction, preUtteranceDelay: 1.0)
            flash(view: tutCircleViews[currentCircleIndex], preBackgroundColour: .yellow, delay: 1.0)
            flash(view: tutCircleViews[currentCircleIndex + 1], preBackgroundColour: .yellow, delay: 1.0)
            
            let animation = DrawingAnimation(duration: 2)
            drawLines(idx1: currentCircleIndex, idx2: currentCircleIndex + 1, drawingAnimation: animation)
        
        /// And so on, until you reach the end
        case 6:
            speak(text: instruction, preUtteranceDelay: 1.0)
            flash(view: tutCircleViews[9], preBackgroundColour: .yellow, delay: 1.0)
            
        default:
            speak(text: instruction, preUtteranceDelay: 1.0)
        }
    }
    
    private func speakMistakes() {
        let labels = K.TMT.labels[numRound]
        let text = "\(K.TMT.mistakeMessages) You should connect \(labels[currentCircleIndex]) to \(labels[currentCircleIndex + 1]).".localized
        setInstructionLabelText(message: text)
        speak(text: text, preUtteranceDelay: 0)
    }
    
    private func speak(text: String, preUtteranceDelay: TimeInterval) {
        let utterance = AVSpeechUtterance(string: text.localized)
        
        // Change synthesizer voice based on app language setting.
        let appLanguage = AppLanguage.shared.getCurrentLanguage()
        
        utterance.voice = AVSpeechSynthesisVoice(language: appLanguage)
        utterance.rate = 0.4
        // utterance.preUtteranceDelay = preUtteranceDelay
        synthesizer?.speak(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isTutorial {
            print("Finished state \(instructionState)")
            
            switch instructionState {
            case 1:
                stopFlashAllCircles()
                
            case 2:
                stopFlash(view: tutCircleViews[currentCircleIndex], postBackgroundColour: .cyan)
                stopFlash(view: tutCircleViews[currentCircleIndex + 1], postBackgroundColour: .green)
                
            case 3:
                stopFlash(view: tutCircleViews[currentCircleIndex], postBackgroundColour: .green)
                stopFlash(view: tutCircleViews[currentCircleIndex + 1], postBackgroundColour: .green)
                
                currentCircleIndex += 1
                
            case 4, 5:
                stopFlash(view: tutCircleViews[currentCircleIndex], postBackgroundColour: .green)
                stopFlash(view: tutCircleViews[currentCircleIndex + 1], postBackgroundColour: .green)
                
                currentCircleIndex += 1
                
            case 6:
                stopFlash(view: tutCircleViews[9], postBackgroundColour: .lightGray)
                hightlightCircle(view: tutCircleViews[9], color: .cyan, delay: nil)
                
            /*
            case 7:
                stopFlash(view: tutCircleViews[currentCircleIndex], postBackgroundColour: .green)
                stopFlash(view: tutCircleViews[currentCircleIndex + 1], postBackgroundColour: .lightGray)
             */
                
            case 10:
                stopFlash(view: tutCircleViews[currentCircleIndex], postBackgroundColour: .green)
                stopFlash(view: tutCircleViews[currentCircleIndex + 1], postBackgroundColour: .lightGray)
                
                canTouch = true
                
            case 11:
                // After user finished connecting all circles
                actionButtonsStackView.isHidden = false
                
            default:
                break
            }
            
            if instructionState < 10 {
                instructionState += 1
                speakInstructions()
            }
        } else {
            initTest()
        }
    }
}

// MARK: - Touch Event Related
extension TMTGameViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isTutorial {
            if canTouch {
                updateOnTouchesBegan(touch: touches.first!, displayView: tutorialView, circleViews: tutCircleViews, idx: currentCircleIndex, circleRadius: tutViewWidth[4])
            }
        } else {
            if canTouch {
                updateOnTouchesBegan(touch: touches.first!, displayView: view, circleViews: testCircleViews, idx: currentCircleIndex, circleRadius: testViewWidth[4])
            }
        }
    }
    
    private func updateOnTouchesBegan(touch: UITouch, displayView: UIView, circleViews: [UIView], idx: Int, circleRadius: CGFloat) {
        let circle = circleViews[idx]
        let currentLocation = touch.location(in: displayView) // To get the location of the touch
        
        firstPoint = currentLocation
        secondPoint = nil
        
        // To determine if one can draw from that Circle
        if (((circle.center.x - currentLocation.x) * (circle.center.x - currentLocation.x)) + ((circle.center.y - currentLocation.y) * (circle.center.y - currentLocation.y))).squareRoot() <= circleRadius {
            canDraw = true
            
            if !isTutorial && circle.backgroundColor != .green {
                gameStatistics[numRound].numCirclesLeft -= 1
                updateStatsLabel()
            }
            
            circle.backgroundColor = .green
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
                
        if isTutorial {
            if canTouch && canDraw {
                for touch in touches {
                    updateOnTouchesMoved(touch: touch, displayView: tutorialView, circleViews: tutCircleViews, circleRadius: tutViewWidth[4])
                }
            }
        } else {
            if canDraw {
                for touch in touches {
                    updateOnTouchesMoved(touch: touch, displayView: view, circleViews: testCircleViews, circleRadius: testViewWidth[4])
                }
            }
        }
    }
    
    private func updateOnTouchesMoved(touch: UITouch, displayView: UIView, circleViews: [UIView], circleRadius: CGFloat) {
        let currentLocation = touch.location(in: displayView)
        
        if firstPoint == nil {
            firstPoint = currentLocation
        }
        secondPoint = currentLocation
        addLine(fromPoint: CGPoint(x: (firstPoint?.x)!, y: (firstPoint?.y)!), toPoint: CGPoint(x: (secondPoint?.x)!, y: (secondPoint?.y)!), drawingAnimation: nil)
        
        for circle in circleViews {
            if (((circle.center.x - currentLocation.x) * (circle.center.x - currentLocation.x)) + ((circle.center.y - currentLocation.y) * (circle.center.y - currentLocation.y))).squareRoot() <= circleRadius {

                // Incorrect circle connected
                if circle.tag > currentCircleIndex + 1 {
                    circle.backgroundColor = .red
                    canDraw = false
                    
                    if isTutorial {
                        speakMistakes()
                        
                        flash(view: tutCircleViews[currentCircleIndex], preBackgroundColour: .yellow, delay: 0)
                        flash(view: tutCircleViews[currentCircleIndex + 1], preBackgroundColour: .yellow, delay: 0)
                        
                        instructionLabel.isHidden = false
                    } else {
                        gameStatistics[numRound].numErrors += 1
                        updateStatsLabel()
                    }

                    continue
                }
                
                // Correct circle connected
                if circle.tag == currentCircleIndex + 1 {
                    // To screenshot the line drawn when the circle is connected correctly
                    lastScreenshot = lineImageView.takeScreenshot()
                    circle.backgroundColor = .green
                    currentCircleIndex += 1
                    
                    if isTutorial {
                        if instructionState == 6 {
                            instructionState += 1
                            canTouch = false
                            canDraw = false
                            speakInstructions()
                        } else {
                            instructionLabel.isHidden = true
                        }
                    } else {
                        gameStatistics[numRound].numCirclesLeft -= 1
                        updateStatsLabel()
                    }
                }
                
                // Finished connecting all circles
                if currentCircleIndex == getNumCircles() - 1 {
                    canDraw = false
                                           
                    if isTutorial {
                        canTouch = false
                        instructionState += 1
                        speakInstructions()
                        
                        instructionLabel.isHidden = false
                        
                    } else {
                        stopTimer()
                        
                        gameStatistics[numRound].totalTimeTaken = K.TMT.numCirclesTimeMapping[TMTResultViewController.numCircles]! - timeLeft
                        endSubTest()
                    }
                }
                
            }
        }
        
        firstPoint = currentLocation
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        firstPoint = nil
        secondPoint = nil

        if isTutorial {
            displayLastScreenshot(reset: false, displayView: tutorialView) // To remove any unwanted lines immediately upon ending touch
            updateOnTouchesEnded(circleViews: tutCircleViews)
        } else {
            // Only increase the numLifts if the circle was not connected correctly
            if canDraw {
                gameStatistics[numRound].numLifts += 1
                updateStatsLabel()
            }
            
            if timeLeft > 0 {
                displayLastScreenshot(reset: false, displayView: view) // To remove any unwanted lines immediately upon ending touch
                updateOnTouchesEnded(circleViews: testCircleViews)
            }
        }
        
        canDraw = false
    }
    
    private func updateOnTouchesEnded(circleViews: [UIView]) {
        // To revert incorrect connected circle to grey colour
        for circle in circleViews {
            if (circle.backgroundColor == .red) {
                circle.backgroundColor = .lightGray
            }
        }
    }
}

// MARK: - Line Drawing
extension TMTGameViewController { // Only used during Tutorial
    
    private struct DrawingAnimation {
        internal let duration: TimeInterval
        
        init(duration: TimeInterval) {
            self.duration = duration
        }
    }
    
    private func drawLines(idx1: Int, idx2: Int, color1: UIColor = .green, color2: UIColor = .green, drawingAnimation: DrawingAnimation?) {
        displayLastScreenshot(reset: false, displayView: tutorialView)
        
        let locationCircle1 = tutCircleCenterPoints[idx1]
        let locationCircle2 = tutCircleCenterPoints[idx2]
        
        addLine(fromPoint: locationCircle1, toPoint: locationCircle2, drawingAnimation: drawingAnimation)
        
        tutCircleViews[idx1].backgroundColor = color1
        tutCircleViews[idx2].backgroundColor = color2
        
        lastScreenshot = lineImageView.takeScreenshot()
    }
    
    private func addLine(fromPoint start: CGPoint, toPoint end: CGPoint, drawingAnimation: DrawingAnimation?) {
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        linePath.fill()

        let line = CAShapeLayer()
        line.lineCap = .round
        line.path = linePath.cgPath
        line.strokeColor = K.TMT.drawColor.cgColor
        line.lineWidth = K.TMT.drawSize
        lineImageView.layer.addSublayer(line)
        
        if let drawingAnimation {
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
            
            animation.duration = drawingAnimation.duration
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            line.strokeEnd = 1.0
            line.add(animation, forKey: "pencilAnimation")
        }
    }
    
    private func loadPencilImage() -> UIImageView {
        let pencilImage = try! UIImage(imageName: "Pencil.png")
        return UIImageView(image: pencilImage)
    }
    
    private func locatePencilImage(at point: CGPoint) {
        
    }
    
    private func movePencilImage(from startPoint: CGPoint, to endPoint: CGPoint) {
        
    }
}

// MARK: - Flash Views
extension TMTGameViewController {
    // consider stop animination after speech later
    private func flash(view: UIView, preBackgroundColour: UIColor, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            view.backgroundColor = preBackgroundColour
        }
        
        UIView.animate(withDuration: K.animateDuration, delay: delay, options: [.curveLinear, .autoreverse, .repeat]) {
            view.alpha = K.animateAlpha
        } completion: { _ in
            return
        }
    }
    
    private func flashAllCircles(delay: TimeInterval) {
        for circleView in tutCircleViews {
            flash(view: circleView, preBackgroundColour: .yellow, delay: delay)
        }
    }
    
    private func stopFlash(view: UIView, postBackgroundColour: UIColor) {
        view.backgroundColor = postBackgroundColour
        view.alpha = 1.0
        view.layer.removeAllAnimations()
    }
    
    private func stopFlashAllCircles() {
        for circleView in tutCircleViews {
            stopFlash(view: circleView, postBackgroundColour: .lightGray)
        }
    }
    
    private func hightlightCircle(view: UIView, color: UIColor, delay: TimeInterval?) {
        if let delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                view.backgroundColor = color
            }
        } else {
            view.backgroundColor = color
        }
    }
}
