//
//  TMTTutorialViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 17/9/21.
//

import UIKit
import Speech
//import AVFoundation

class TMTTutorialViewController: UIViewController {
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var actionButtonsStackView: UIStackView!
    
    // Speech Synthesis
    private var synthesizer: AVSpeechSynthesizer?
    private var instructionState = 0
    
    // ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25"]
    // ["1","A","2","B","3","C","4","D","5","E","6","F","7","G","8","H","9","I","10","J","11","K","12","L","13"]
    var currentLabels: [String] = []
    
    // Line Drawing
    var currentUIViewForCircles = UIView()
    var lineImageView = UIImageView() // old: myImageView - to render lines drawn
    var lastScreenshot = UIImage()
    
    var isTutorial = true
//    var isMistake = false
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
    var timeLeft: Int = K.TMT.totalTime {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        initTutorial(state: 0)
//        initTest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
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
    
    private func initTutorial(state: Int) {
        instructionLabel.isHidden = false
        tutorialView.isHidden = false
        
        currentUIViewForCircles = tutorialView
        tutCircleViews = removeCirclesFromView(circleViews: tutCircleViews)
        testCircleViews = removeCirclesFromView(circleViews: testCircleViews)
        displayLastScreenshot(reset: true, displayView: tutorialView)
        displayLastScreenshot(reset: true, displayView: view)
        
        tutViewWidth = tutorialView.bounds.width
        tutViewHeight = tutorialView.bounds.height
        
        tutorialView.layer.borderWidth = 2.0
        tutorialView.layer.borderColor = UIColor(named: "Purple")?.cgColor
        
//        tutCircleCenterPoints = [
//            CGPoint(x: tutViewWidth[10], y: tutViewHeight[10]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[30]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[70]), CGPoint(x: tutViewWidth[10], y: tutViewHeight[30]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[10]),
//            CGPoint(x: tutViewWidth[10], y: tutViewHeight[50]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[50]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[50]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[70]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[70]),
//            CGPoint(x: tutViewWidth[10], y: tutViewHeight[70]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[10]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[10]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[50]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[90]),
//            CGPoint(x: tutViewWidth[90], y: tutViewHeight[70]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[30]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[30]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[30]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[90]),
//            CGPoint(x: tutViewWidth[10], y: tutViewHeight[90]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[90]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[10]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[50]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[90])
//        ]
        
        tutCircleCenterPoints = [
            CGPoint(x: tutViewWidth[10], y: tutViewHeight[15]), CGPoint(x: tutViewWidth[10], y: tutViewHeight[35]), CGPoint(x: tutViewWidth[10], y: tutViewHeight[55]), CGPoint(x: tutViewWidth[10], y: tutViewHeight[75]), CGPoint(x: tutViewWidth[10], y: tutViewHeight[90]),
            CGPoint(x: tutViewWidth[30], y: tutViewHeight[15]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[35]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[55]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[75]), CGPoint(x: tutViewWidth[30], y: tutViewHeight[90]),
            CGPoint(x: tutViewWidth[50], y: tutViewHeight[15]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[35]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[55]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[75]), CGPoint(x: tutViewWidth[50], y: tutViewHeight[90]),
            CGPoint(x: tutViewWidth[70], y: tutViewHeight[15]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[35]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[55]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[75]), CGPoint(x: tutViewWidth[70], y: tutViewHeight[90]),
            CGPoint(x: tutViewWidth[90], y: tutViewHeight[15]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[35]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[55]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[75]), CGPoint(x: tutViewWidth[90], y: tutViewHeight[90]),
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
        instructionLabel.isHidden = true
        tutorialView.isHidden = true
        
        currentUIViewForCircles = view
        tutCircleViews = removeCirclesFromView(circleViews: tutCircleViews)
        testCircleViews = removeCirclesFromView(circleViews: testCircleViews)
        displayLastScreenshot(reset: true, displayView: tutorialView)
        displayLastScreenshot(reset: true, displayView: view)
        
        testViewWidth = view.bounds.width - 125
        testViewHeight = view.bounds.height - 25
        
        testCircleCenterPoints = [
            CGPoint(x: testViewWidth[10], y: testViewHeight[15]), CGPoint(x: testViewWidth[10], y: testViewHeight[35]), CGPoint(x: testViewWidth[10], y: testViewHeight[55]), CGPoint(x: testViewWidth[10], y: testViewHeight[75]), CGPoint(x: testViewWidth[10], y: testViewHeight[90]),
            CGPoint(x: testViewWidth[30], y: testViewHeight[15]), CGPoint(x: testViewWidth[30], y: testViewHeight[35]), CGPoint(x: testViewWidth[30], y: testViewHeight[55]), CGPoint(x: testViewWidth[30], y: testViewHeight[75]), CGPoint(x: testViewWidth[30], y: testViewHeight[90]),
            CGPoint(x: testViewWidth[50], y: testViewHeight[15]), CGPoint(x: testViewWidth[50], y: testViewHeight[35]), CGPoint(x: testViewWidth[50], y: testViewHeight[55]), CGPoint(x: testViewWidth[50], y: testViewHeight[75]), CGPoint(x: testViewWidth[50], y: testViewHeight[90]),
            CGPoint(x: testViewWidth[70], y: testViewHeight[15]), CGPoint(x: testViewWidth[70], y: testViewHeight[35]), CGPoint(x: testViewWidth[70], y: testViewHeight[55]), CGPoint(x: testViewWidth[70], y: testViewHeight[75]), CGPoint(x: testViewWidth[70], y: testViewHeight[90]),
            CGPoint(x: testViewWidth[90], y: testViewHeight[15]), CGPoint(x: testViewWidth[90], y: testViewHeight[35]), CGPoint(x: testViewWidth[90], y: testViewHeight[55]), CGPoint(x: testViewWidth[90], y: testViewHeight[75]), CGPoint(x: testViewWidth[90], y: testViewHeight[90]),
        ]
        
        currentLabels = K.TMT.labels[numRound] // Start with Round 0
        stopTimer()

        currentCircleIndex = 0
        
        isTutorial = false
        canTouch = true
        canDraw = false
        
        actionButtonsStackView.isHidden = true
        statsStackView.isHidden = false
        
        gameStatistics[numRound].numCirclesLeft = currentLabels.count
        gameStatistics[numRound].numErrors = 0
        gameStatistics[numRound].numLifts = 0
        updateStatsLabel()
        
        createNewTestCircles()
        startTimer()
    }
    
    private func startTimer(){
        timeLeft = K.TMT.totalTime
        isTimerPlaying = true
    }

    private func stopTimer(){
        // timeLeft = K.TMT.totalTime
        isTimerPlaying = false
    }
    
    @objc func updateTimer(){
        if isTimerPlaying {
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                gameStatistics[numRound].totalTimeTaken = 301

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
            
            actionButtonsStackView.isHidden = true
            displayLastScreenshot(reset: true, displayView: tutorialView) // Reset display from Tutorial
            for circleView in tutCircleViews {
                circleView.backgroundColor = .lightGray
            }
            
            let text = "There are a total of 25 circles. Please connect them without lifting the stylus as much as possible. You have \(K.TMT.totalTime) seconds. You may begin now."
            
            setInstructionLabelText(message: text)
            speak(text: text, preUtteranceDelay: 0.5)
            
            // Init Test is performed in didFinish(:) after speech is done.
        }
    }
    
    private func createCircleView(idx: Int, width: CGFloat, height: CGFloat, centerX: CGFloat, centerY: CGFloat) -> UIView {
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: width[5], height: width[5])) // Set width = height to create a circular view
        circleView.center = CGPoint(x: centerX, y: centerY)
        circleView.backgroundColor = .lightGray
        circleView.layer.cornerRadius = width[2.5] // Same as "circleView.frame.size.width / 2"
        circleView.layer.borderWidth = width[0.20]
        circleView.layer.borderColor = UIColor.black.cgColor
        circleView.tag = idx

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width[5], height: width[5]))
        label.text = currentLabels[idx]
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 30)
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
        
        for idx in 0...tutCircleCenterPoints.count - 1 {
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
        
        for idx in 0...testCircleCenterPoints.count - 1 {
            let testCircleView = createCircleView(
                idx: idx,
                width: testViewWidth,
                height: testViewHeight,
                centerX: testCircleCenterPoints[idx].x + CGFloat(Int.random(in: -30..<30)),
                centerY: testCircleCenterPoints[idx].y + CGFloat(Int.random(in: -30..<30))
            )
            view.addSubview(testCircleView)
            testCircleViews.append(testCircleView)
        }
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
extension TMTTutorialViewController: AVSpeechSynthesizerDelegate {
    private func initSynthesizer() {
        synthesizer = AVSpeechSynthesizer()
        synthesizer?.delegate = self
    }
    
    private func speakInstructions() {
        print("numRound: \(numRound)")
        print("instructionState: \(instructionState)")
        
        let instructions = K.TMT.instructions[numRound]
        
        if instructionState == instructions.count || !isTutorial {
            return
        }
        
        let instruction = instructions[instructionState] // To get instructions for either test A or B
        setInstructionLabelText(message: instruction)

        switch instructionState {
        case 0, 1, 6, 7:
            speak(text: instruction, preUtteranceDelay: 0.5)
            break
        case 2:
            speak(text: instruction, preUtteranceDelay: 1.0)
            flashAllCircles(delay: 1.0)
            break
        case 3, 4, 5:
            speak(text: instruction, preUtteranceDelay: 1.0)
            flash(view: tutCircleViews[currentCircleIndex], preBackgroundColour: .yellow, delay: 1.0)
            flash(view: tutCircleViews[currentCircleIndex + 1], preBackgroundColour: .yellow, delay: 1.0)
            break
        default:
            speak(text: instruction, preUtteranceDelay: 1.0)
            break
        }
    }
    
    private func speakMistakes() {
        let labels = K.TMT.labels[numRound]
        let text = "\(K.TMT.mistakeMessages) You should connect \(labels[currentCircleIndex]) to \(labels[currentCircleIndex + 1])."
        setInstructionLabelText(message: text)
        speak(text: text, preUtteranceDelay: 0)
    }
    
    private func speak(text: String, preUtteranceDelay: TimeInterval) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")
        utterance.rate = K.UtteranceRate.instruction
        utterance.preUtteranceDelay = preUtteranceDelay
        synthesizer?.speak(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isTutorial {
            print("Finished state \(instructionState)")
            
            switch instructionState {
            case 2:
                stopFlashAllCircles()
                break
            case 3, 4:
                stopFlash(view: tutCircleViews[currentCircleIndex], postBackgroundColour: .green)
                stopFlash(view: tutCircleViews[currentCircleIndex + 1], postBackgroundColour: .green)
                
                drawLines(idx1: currentCircleIndex, idx2: currentCircleIndex + 1)
                currentCircleIndex += 1
                break
            case 5, 6:
                stopFlash(view: tutCircleViews[currentCircleIndex], postBackgroundColour: .green)
                stopFlash(view: tutCircleViews[currentCircleIndex + 1], postBackgroundColour: .lightGray)
                
                // Allow users to start drawing from 3 to 4, and subsequent numbers
                canTouch = true
                break
            case 7:
                // After user finished connecting all circles
                actionButtonsStackView.isHidden = false
            default:
                break
            }
            
            if instructionState < 5 {
                instructionState += 1
                speakInstructions()
            }
        } else {
            initTest()
        }
    }
}

// MARK: - Touch Event Related
extension TMTTutorialViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isTutorial {
            if canTouch {
                updateOnTouchesBegan(touch: touches.first!, displayView: tutorialView, circleViews: tutCircleViews, idx: currentCircleIndex, circleRadius: tutViewWidth[2.5])
            }
        } else {
            if canTouch {
                updateOnTouchesBegan(touch: touches.first!, displayView: view, circleViews: testCircleViews, idx: currentCircleIndex, circleRadius: testViewWidth[2.5])
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
                    updateOnTouchesMoved(touch: touch, displayView: tutorialView, circleViews: tutCircleViews, circleRadius: tutViewWidth[2.5])
                }
            }
        } else {
            if canDraw {
                for touch in touches {
                    updateOnTouchesMoved(touch: touch, displayView: view, circleViews: testCircleViews, circleRadius: testViewWidth[2.5])
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
        addLine(fromPoint: CGPoint(x: (firstPoint?.x)!, y: (firstPoint?.y)!), toPoint: CGPoint(x: (secondPoint?.x)!, y: (secondPoint?.y)!))
        
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
                        if instructionState == 5 {
                            instructionState += 1
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
                if currentCircleIndex == currentLabels.count - 1 {
                    canDraw = false
                                           
                    if isTutorial {
                        canTouch = false
                        instructionState += 1
                        speakInstructions()
                        
                        instructionLabel.isHidden = false
                    } else {
                        stopTimer()
                        
                        gameStatistics[numRound].totalTimeTaken = K.TMT.totalTime - timeLeft
                        // endSubTest()
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
extension TMTTutorialViewController {
    // Only used during Tutorial
    private func drawLines(idx1: Int, idx2: Int) {
        displayLastScreenshot(reset: false, displayView: tutorialView)
        
        let locationCircle1 = tutCircleCenterPoints[idx1]
        let locationCircle2 = tutCircleCenterPoints[idx2]
        
        addLine(fromPoint: locationCircle1, toPoint: locationCircle2)
        tutCircleViews[idx1].backgroundColor = .green
        tutCircleViews[idx2].backgroundColor = .green
        
        lastScreenshot = lineImageView.takeScreenshot()
    }
    
    func addLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
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
    }
}

// MARK: - Flash Views
extension TMTTutorialViewController {
    // consider stop animination after speech later
    private func flash(view: UIView, preBackgroundColour: UIColor, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            view.backgroundColor = preBackgroundColour
        }
        
        UIView.animate(withDuration: 0.5, delay: delay, options: [.curveLinear, .autoreverse, .repeat]) {
            view.alpha = 0.35
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
}

// MARK: - For experimenting with drawing
extension TMTTutorialViewController {
    private func testDrawing(idx1: Int, idx2: Int) {
        // displayLastScreenshot()
        // If it is meant to reset the whole screen, remove all the lines.
//         if true {
//            lastScreenshot = UIImage()
//         }
        
        // To reinitialise lineImageView, and set the image to be the last drawn lines. Useful to remove errornous lines.
        lineImageView = UIImageView(frame: tutorialView.bounds)
        lineImageView.backgroundColor = .yellow
        lineImageView.image = lastScreenshot
        lineImageView.layer.zPosition = -1 // Circle Views needs to be closer to the user than the LineImageView
        tutorialView.addSubview(lineImageView)

        // drawLines() part 1
        let locationCircle1 = tutCircleCenterPoints[idx1]
        let locationCircle2 = tutCircleCenterPoints[idx2]

        // addLine()
        let linePath = UIBezierPath()
        linePath.move(to: locationCircle1)
        linePath.addLine(to: locationCircle2)
        linePath.fill()

        let line = CAShapeLayer()
        line.lineCap = .round
        line.path = linePath.cgPath
        line.strokeColor = K.TMT.drawColor.cgColor
        line.lineWidth = K.TMT.drawSize
        lineImageView.layer.addSublayer(line)

        // drawLines() part 2
        tutCircleViews[idx1].backgroundColor = .green
        tutCircleViews[idx2].backgroundColor = .green

        lastScreenshot = lineImageView.takeScreenshot()
    }
}
