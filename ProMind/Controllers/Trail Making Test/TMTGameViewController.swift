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
    
    var drawSize: CGFloat = 5.0
    var drawColor = UIColor.blue
    
    var myImageView = UIImageView()
    var imageView2 = UIImageView()
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
    let labels = [
        ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25"],
        ["1","A","2","B","3","C","4","D","5","E","6","F","7","G","8","H","9","I","10","J","11","K","12","L","13"]
    ]
    var numRound = 0
    var currentLabels: [String] = []

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

    var lastScreenshot = UIImage()
    var canDraw: Bool = false
    
    // For stats
//    var lastTime: Int = 0 {
//        didSet {
//            setStatLabel()
//        }
//    }
    
    var gameStatistics: [GameStatistics] = [GameStatistics(), GameStatistics()]
    
    private func updateStatsLabel() {
        statsLabel.isHidden = false
        statsLabel.attributedText = gameStatistics[numRound].getFormattedGameStats()
    }
    
    private func printCGFloatSubscript(idx: CGFloat) {
        print("w[\(idx)]=\(w[idx]); h[\(idx)]=\(h[idx]);")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a Timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        // view represents the root view of a View Controller
        /// The bounds of an UIView is the rectangle, expressed as a location (x,y) and size (width,height)
        /// relative to its own coordinate system (0,0).
        /// The frame of an UIView is the rectangle, expressed as a location (x,y) and size (width,height)
        /// relative to the superview it is contained within.
        h = view.bounds.height
        w = view.bounds.width - 100
        print("Width=\(w); Height=\(h);")
        
        allPointsCentersArray = [
            CGPoint(x: w[10], y: h[15]), CGPoint(x: w[10], y: h[35]), CGPoint(x: w[10], y: h[55]), CGPoint(x: w[10], y: h[75]), CGPoint(x: w[10], y: h[90]),
            CGPoint(x: w[30], y: h[15]), CGPoint(x: w[30], y: h[35]), CGPoint(x: w[30], y: h[55]), CGPoint(x: w[30], y: h[75]), CGPoint(x: w[30], y: h[90]),
            CGPoint(x: w[50], y: h[15]), CGPoint(x: w[50], y: h[35]), CGPoint(x: w[50], y: h[55]), CGPoint(x: w[50], y: h[75]), CGPoint(x: w[50], y: h[90]),
            CGPoint(x: w[70], y: h[15]), CGPoint(x: w[70], y: h[35]), CGPoint(x: w[70], y: h[55]), CGPoint(x: w[70], y: h[75]), CGPoint(x: w[70], y: h[90]),
            CGPoint(x: w[90], y: h[15]), CGPoint(x: w[90], y: h[35]), CGPoint(x: w[90], y: h[55]), CGPoint(x: w[90], y: h[75]), CGPoint(x: w[90], y: h[90]),
        ]
        
        numRound = 0
        currentLabels = labels[numRound]
        
        initGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
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

        createNewCircles()
        
        displayLastScreenshot(reset: true)
        
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
//                lastTime = 301
                stopTimer()
                canDraw = false

                for circle in circleViews {
                    // Unattempted circles will be shown as Red
                    if circle.backgroundColor == .lightGray {
                        circle.backgroundColor = .red
                    }
                }
            }
        }
    }

    func createNewCircles() {
        // allPointsCentersArray.shuffle()

        for circleView in circleViews {
            circleView.removeFromSuperview()
        }
        circleViews = []
        
        for idx in 0...allPointsCentersArray.count - 1 {
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: w[5], height: w[5]))
            // circleView.center = CGPoint(x: allPointsCentersArray[idx].x + CGFloat(Int.random(in: -30..<30)), y: allPointsCentersArray[idx].y + CGFloat(Int.random(in: -30..<30)))
            circleView.center = CGPoint(x: allPointsCentersArray[idx].x, y: allPointsCentersArray[idx].y)
            
            circleView.backgroundColor = .lightGray
            circleView.layer.cornerRadius = w[2.5]
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
        
        // To determine if one can draw from that Circle
        if (((circle.center.x - currentLocation.x) * (circle.center.x - currentLocation.x)) + ((circle.center.y - currentLocation.y) * (circle.center.y - currentLocation.y))).squareRoot() < w[2.2] &&
            timeLeft != 0 {
            canDraw = true
        }
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

                    if (((circle.center.x - currentLocation.x) * (circle.center.x - currentLocation.x)) + ((circle.center.y - currentLocation.y) * (circle.center.y - currentLocation.y))).squareRoot() < w[2.2] {

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

                            gameStatistics[numRound].totalTimeTaken = K.TMT.totalTime - timeLeft
                            
                            if numRound == 0 {
                                // Enter TMT-B
                                // Display TMT-B Instructions
                                numRound = 1
                                currentLabels = labels[numRound]
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                    self.initGame()
                                })
                            } else {
                                // End Game
                                // Present scores
                            }

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
            
            //            imageView2.removeFromSuperview()
            //            imageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: w, height: h))
            //            imageView2.backgroundColor = .white
            //            imageView2.image = lastImage
            //            myImageView.addSubview(imageView2)
            //            allImageViews.append(imageView2)
            
            layerCount = 0
            
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
        line.strokeColor = drawColor.cgColor
        line.lineWidth = drawSize

        allLines[layerCount] = line
        self.allImageViews[allImageViews.count - 1].layer.addSublayer(allLines[layerCount]!)
        layerCount += 1
        allLayerCount += 1
    }
}

extension UIView {
    func takeScreenshot() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if image != nil {
            return image!
        }

        return UIImage()
    }
}
