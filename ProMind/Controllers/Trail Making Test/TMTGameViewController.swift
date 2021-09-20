//
//  TMTGameViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 5/7/21.
//

import UIKit

class TMTGameViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    var w: CGFloat = 0.0
    var h: CGFloat = 0.0
    
    var myImageView = UIImageView()
    var allImageViews = [UIImageView]()
    
    var firstPoint: CGPoint?
    var secondPoint: CGPoint?
    
    var layerCount = 0
    var allLayerCount = 0
    var allLines = [Int:CAShapeLayer]()
    var border = UIView()
    
    var circleViews = [UIView]()
    var rigthViewIndex = 0
    var currentViewIndex = 0
    
    var allPointsCentersArray: [CGPoint] = []
    var numRound = 0
    var currentLabels: [String] = []

    var timer = Timer()
    var timeLeft: Int = K.TMT.numCirclesTimeMapping[25]! {
        didSet {
            let timerText = NSMutableAttributedString(string: "Time Left: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
            timerText.append(NSMutableAttributedString(string: "\(timeLeft) s"))
            timerLabel.attributedText = timerText
            
            timerLabel.isHidden = false
        }
    }
    var isTimerPlaying = false

    var lastScreenshot = UIImage()
    var canDraw: Bool = false
    
    var gameStatistics: [TMTGameStatistics] = [TMTGameStatistics(), TMTGameStatistics()]
    
    private func updateStatsLabel() {
        statsLabel.isHidden = false
        statsLabel.attributedText = gameStatistics[numRound].getFormattedGameStats()
    }
    
    private func printCGFloatSubscript(idx: CGFloat) {
        print("w[\(idx)]=\(w[idx]); h[\(idx)]=\(h[idx]);")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view represents the root view of a View Controller
        /// The bounds of an UIView is the rectangle, expressed as a location (x,y) and size (width,height)
        /// relative to its own coordinate system (0,0).
        /// The frame of an UIView is the rectangle, expressed as a location (x,y) and size (width,height)
        /// relative to the superview it is contained within.
        h = view.bounds.height - 25
        w = view.bounds.width - 125
        print("Width=\(w); Height=\(h);")
        
        allPointsCentersArray = [
            CGPoint(x: w[10], y: h[15]), CGPoint(x: w[10], y: h[35]), CGPoint(x: w[10], y: h[55]), CGPoint(x: w[10], y: h[75]), CGPoint(x: w[10], y: h[90]),
            CGPoint(x: w[30], y: h[15]), CGPoint(x: w[30], y: h[35]), CGPoint(x: w[30], y: h[55]), CGPoint(x: w[30], y: h[75]), CGPoint(x: w[30], y: h[90]),
            CGPoint(x: w[50], y: h[15]), CGPoint(x: w[50], y: h[35]), CGPoint(x: w[50], y: h[55]), CGPoint(x: w[50], y: h[75]), CGPoint(x: w[50], y: h[90]),
            CGPoint(x: w[70], y: h[15]), CGPoint(x: w[70], y: h[35]), CGPoint(x: w[70], y: h[55]), CGPoint(x: w[70], y: h[75]), CGPoint(x: w[70], y: h[90]),
            CGPoint(x: w[90], y: h[15]), CGPoint(x: w[90], y: h[35]), CGPoint(x: w[90], y: h[55]), CGPoint(x: w[90], y: h[75]), CGPoint(x: w[90], y: h[90]),
        ]
        
        numRound = 0
        currentLabels = K.TMT.labels[numRound]
        
        createNewCircles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a Timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        showDialog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func showDialog() {
        var title: String
        var msg: String
        
        if numRound == 0 {
            title = "\(K.TMT.TrailMakingTest) A"
            msg = "\n\(K.TMT.TrailMakingTest) A is the first part of the test. \n\nIt requires you to connect a series of 25 numbered circles in ascending order\n(i.e., 1-2-3-...-23-24-25)"
        } else {
            title = "\(K.TMT.TrailMakingTest) B"
            msg = "\n\(K.TMT.TrailMakingTest) B is the second part of the test. \n\nIt requires you to connect 25 circles labelled with numbers and letters in the alternating sequence of 1-A-2-B-3-C...)"
        }
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alertController.setTitle(font: UIFont.boldSystemFont(ofSize: 24), color: .black)
        alertController.setMessage(font: UIFont(name: "System", size: 18), color: UIColor(named: "Grey"))
        
        alertController.addAction(UIAlertAction(title: "Begin", style: UIAlertAction.Style.default, handler: { _ in
            self.initGame()
        }))
        // alertController.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: { _ in
        //    self.dismiss(animated: true, completion: nil)
        // }))

        self.present(alertController, animated: true, completion: nil)
    }
    
    private func initGame() {
        stopTimer()

        canDraw = false
        
        statsLabel.isHidden = true
        timerLabel.isHidden = true
        
        gameStatistics[numRound].numCirclesLeft = currentLabels.count
        gameStatistics[numRound].numErrors = 0
        gameStatistics[numRound].numLifts = 0
        updateStatsLabel()
        
        layerCount = 0

        rigthViewIndex = 0
        currentViewIndex = 0
        
        displayLastScreenshot(reset: true)
        
        startTimer()
    }
    
    private func startTimer(){
        timeLeft = K.TMT.numCirclesTimeMapping[25]!
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

                for circle in circleViews {
                    // Unattempted circles will be shown as Red
                    if circle.backgroundColor == .lightGray {
                        circle.backgroundColor = .red
                    }
                }
                
                endSubTest()
            }
        }
    }

    func createNewCircles() {
         allPointsCentersArray.shuffle()

        for circleView in circleViews {
            circleView.removeFromSuperview()
        }
        circleViews = []
        
        for idx in 0...allPointsCentersArray.count - 1 {
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: w[5], height: w[5]))
            circleView.center = CGPoint(x: allPointsCentersArray[idx].x + CGFloat(Int.random(in: -30..<30)), y: allPointsCentersArray[idx].y + CGFloat(Int.random(in: -30..<30)))
            // circleView.center = CGPoint(x: allPointsCentersArray[idx].x, y: allPointsCentersArray[idx].y)
            
            circleView.backgroundColor = .lightGray
            circleView.layer.cornerRadius = w[2.5]
            // circleView.layer.cornerRadius = circleView.frame.size.width / 2 // Same as w[2.5]...
            circleView.layer.borderWidth = w[0.20]
            circleView.layer.borderColor = UIColor.black.cgColor
            circleView.tag = idx

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: w[5], height: w[5]))
            label.text = currentLabels[idx]
            label.textAlignment = .center
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 30)
            label.adjustsFontForContentSizeCategory = true
            circleView.addSubview(label)

            view.addSubview(circleView)
            circleViews.append(circleView)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first!
        let currentLocation = touch.location(in:self.view) // To get the location of the touch
        
        let circle = circleViews[currentViewIndex]
        
        firstPoint = currentLocation
        secondPoint = nil
        
        // printCircleTouchable(circle: circle, currentLocation: currentLocation)
        
        // To determine if one can draw from that Circle
        if (((circle.center.x - currentLocation.x) * (circle.center.x - currentLocation.x)) + ((circle.center.y - currentLocation.y) * (circle.center.y - currentLocation.y))).squareRoot() <= w[2.5] && // Original: w[2.2]
            timeLeft != 0 {
            canDraw = true
        }
    }
    
    private func printCircleTouchable(circle: UIView, currentLocation: CGPoint) {
        print("  circle.center.x: ", circle.center.x)
        print("currentLocation.x: ", currentLocation.x)
        print("  circle.center.y: ", circle.center.y)
        print("currentLocation.y: ", currentLocation.y)
        print("           w[2.5]: ", w[2.5])
        
        print("equation1: ", (((circle.center.x - currentLocation.x) * (circle.center.x - currentLocation.x)) + ((circle.center.y - currentLocation.y) * (circle.center.y - currentLocation.y))).squareRoot())
        print("equation2: ", (pow(circle.center.x - currentLocation.x, 2) + pow(circle.center.y - currentLocation.y, 2)).squareRoot())
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if canDraw {
            for currentTouch in touches {
                let currentLocation = currentTouch.location(in:self.view)
                
                if firstPoint == nil {
                    firstPoint = currentLocation
                }
                secondPoint = currentLocation
                addLine(fromPoint: CGPoint(x: (firstPoint?.x)!, y: (firstPoint?.y)!), toPoint: CGPoint(x: (secondPoint?.x)!, y: (secondPoint?.y)!))

                for circle in circleViews {

                    // printCircleTouchable(circle: circle, currentLocation: currentLocation)
                    
                    if (((circle.center.x - currentLocation.x) * (circle.center.x - currentLocation.x)) + ((circle.center.y - currentLocation.y) * (circle.center.y - currentLocation.y))).squareRoot() <= w[2.5] {

                        // Incorrect circle connected
                        if circle.tag > rigthViewIndex {
                            circle.backgroundColor = .red
                            canDraw = false
                            gameStatistics[numRound].numErrors += 1
                            updateStatsLabel()
                            
                            continue
                        }
                        
                        // Correct circle connected
                        if circle.tag == rigthViewIndex {
                            // To screenshot the line drawn when the circle is connected correctly
                            lastScreenshot = myImageView.takeScreenshot()
                            circle.backgroundColor = .green
                            currentViewIndex = rigthViewIndex
                            rigthViewIndex = rigthViewIndex + 1
                            gameStatistics[numRound].numCirclesLeft -= 1
                            updateStatsLabel()
                        }
                        
                        
                        if currentViewIndex == currentLabels.count - 1 {
                            stopTimer()
                            canDraw = false
                            
                            gameStatistics[numRound].totalTimeTaken = K.TMT.numCirclesTimeMapping[25]! - timeLeft
                            endSubTest()
                        }
                        
                    }
                }
                
                firstPoint = currentLocation
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        firstPoint = nil
        secondPoint = nil

        // Only increase the numLifts if the circle was not connected correctly
        if canDraw {
            gameStatistics[numRound].numLifts += 1
            updateStatsLabel()
        }

        canDraw = false

        if timeLeft > 0 {
            displayLastScreenshot(reset: false)
            
            layerCount = 0
            
            // To revert incorrect connected circle to grey colour
            for circle in circleViews {
                if (circle.backgroundColor == .red) {
                    circle.backgroundColor = .lightGray
                }
            }
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        initGame()
    }
    
    private func displayLastScreenshot(reset: Bool) {
        // If it is meant to reset the whole screen, remove all the lines.
        if reset {
            lastScreenshot = UIImage()
        }
    
        myImageView.removeFromSuperview()
        
        myImageView = UIImageView(frame: view.frame)
        myImageView.backgroundColor = .white
        myImageView.image = lastScreenshot
        myImageView.layer.zPosition = -1
        view.addSubview(myImageView)
        
        allImageViews.append(myImageView)
    }
     
    func addLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        linePath.fill()

        line.lineCap = CAShapeLayerLineCap.round
        line.path = linePath.cgPath
        line.strokeColor = K.TMT.drawColor.cgColor
        line.lineWidth = K.TMT.drawSize

        allLines[layerCount] = line
        self.allImageViews[allImageViews.count - 1].layer.addSublayer(allLines[layerCount]!)
        layerCount += 1
        allLayerCount += 1
    }
    
    private func endSubTest() {
        if numRound == 0 {
            // Enter TMT-B
            // Display TMT-B Instructions
            numRound = 1
            currentLabels = K.TMT.labels[numRound]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.displayLastScreenshot(reset: true)
                self.createNewCircles()
                self.showDialog()
            })
        } else {
            // End Game
            // Present scores
            self.performSegue(withIdentifier: K.TMT.goToTMTResultSegue, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tmtResultViewController = segue.destination as! TMTResultViewController
        tmtResultViewController.gameResultStatistics = gameStatistics
    }
}

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitle(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont], range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor], range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : messageFont], range: NSMakeRange(0, message.utf8.count))
        }
        
        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor], range: NSMakeRange(0, message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}

