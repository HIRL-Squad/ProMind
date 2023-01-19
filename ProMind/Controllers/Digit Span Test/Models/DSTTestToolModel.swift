//
//  DSTTestToolModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 28/6/22.
//

import Foundation
import UIKit

class RepeatingTimer {
    
    internal var tolerance: Double
    
    private var counter: UInt = 0
    private var timer: Timer?
    private var savedTime: Int = 0
    private let viewModel: DSTViewModels
    
    internal var testType: DSTTestType?
    
    private let notificationBroadcast = NotificationBroadcast()
    
    init(tolerance: Double, viewModel: DSTViewModels) {
        self.tolerance = tolerance
        self.viewModel = viewModel
    }
    
    deinit {
        timer?.invalidate()
        counter = 0
    }
    
    internal func start() {
        counter = 0
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(increment), userInfo: nil, repeats: true)
        timer?.tolerance = tolerance
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    internal func getRunningTime() -> UInt {
        return counter
    }
    
    internal func pause() {
        timer?.invalidate()
    }
    
    internal func resume() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(increment), userInfo: nil, repeats: true)
        timer?.tolerance = tolerance
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    internal func end() {
        timer?.invalidate()
        counter = 0
    }
    
    @objc private func increment() throws {
        counter = counter &+ 1
        
        guard testType != nil else {
            print("Test type is nil for timer increment!\n")
            throw TimerError.nilTestType
        }
        
        notificationBroadcast.post("Timer Increment \(viewModel)", object: (testType, counter))
    }
}

struct TestDigitsGenerator {
    
    internal func generateNoneRepeatingRandomNumbers(numberOfDigits: Int) -> String {
        let shuffledArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].shuffled()
        let arraySlice = shuffledArray[..<numberOfDigits]
        let resultArray = Array(arraySlice)
        
        var resultString: String = "\(resultArray[0])"
        for index in 1..<resultArray.count {
            resultString.append(" - \(resultArray[index])")
        }
        
        return resultString
    }
    
    internal func generateNormalRandomNumbers(numberOfDigits: Int) -> String {
        var resultString: String = "\(Int.random(in: 0...9))"
        
        for _ in 0..<numberOfDigits - 1 {
            resultString.append(" - \(Int.random(in: 0...9))")
        }
        
        return resultString
    }
}

class Rectangle {
    
    internal var x, y: CGFloat
    internal var width, height: CGFloat
    
    internal var origin: CGPoint
    internal var size: CGSize
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        
        self.origin = CGPoint(x: self.x, y: self.y)
        self.size = CGSize(width: self.width, height: self.height)
    }
    
    internal func makeRectangle() -> CGRect {
        return CGRect(origin: origin, size: size)
    }
}

class SpokenDigitRectangle: Rectangle {
    
    internal var fillColor: CGColor?
    internal var strokeColor: CGColor?
    internal var lineWidth: CGFloat?
    
    override init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(x: x, y: y, width: width, height: height)
    }
    
    internal func drawDigitRectangle() {
        
    }
    
    internal func makeDigitRectangle(maxX: CGFloat, maxY: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: maxX, height: maxY))
        
        let image = renderer.image { (context) in
            
            if let fillColor = fillColor {
                context.cgContext.setFillColor(fillColor)
            }
            if let strokeColor = strokeColor {
                context.cgContext.setStrokeColor(strokeColor)
            }
            if let lineWidth = lineWidth {
                context.cgContext.setLineWidth(lineWidth)
            }
            
            let rectangle = makeRectangle()
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        return image
    }
    
    internal func insertDigits(text: String, font: UIFont) {
        let rectangle = makeRectangle()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.red
        ]
        NSAttributedString(string: text, attributes: attributes).draw(in: rectangle.insetBy(dx: 0, dy: (rectangle.height - font.pointSize)/2))
    }
}

class SpokenResultFilter {
    
    internal let spokenResult: String
    internal let viewModel: DSTViewModels
    private let notificationBroadcast = NotificationBroadcast()
    
    init(spokenResult: String, viewModel: DSTViewModels) {
        self.spokenResult = spokenResult
        self.viewModel = viewModel
    }
    
    internal func getFilteredResult() -> String {
        var filteredResult: String = spokenResult
        let decimalNumberDictionary: [String: String] = [
            "zero": "0", "one": "1", "two": "2", "three": "3", "four": "4",
            "five": "5", "six": "6", "seven": "7", "eight": "8", "nine": "9"
        ]
        
        /// To check if spoken result contains decimal number words (like "one") and convert those words to digit number.
        /// This process is necessary since the first speaking digit will be recognised as words instead of a digit number.
        if decimalNumberDictionary.keys.contains(where: spokenResult.lowercased().contains) {
            for key in decimalNumberDictionary.keys {
                if spokenResult.lowercased() == key {
                    if let value = decimalNumberDictionary[key] {
                        filteredResult = value
                        break
                    }
                }
            }
        }
        
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: filteredResult)) {
            notificationBroadcast.post("Legal Spoken Result \(viewModel)", object: nil)
        } else {
            filteredResult = "   " // Empty string will result in "Out of bounds" for extension UILabel func setCharacterSpacing().
            notificationBroadcast.post("Illegal Spoken Result \(viewModel)", object: nil)
        }
        
        return filteredResult
    }
}
