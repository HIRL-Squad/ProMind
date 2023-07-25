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
    private let spokenResult: String
    private let expectedResult: String
    private let viewModel: DSTViewModels
    private let notificationBroadcast = NotificationBroadcast()
    
    init(spokenResult: String, expectedResult: String, viewModel: DSTViewModels) {
        self.spokenResult = spokenResult
        self.expectedResult = expectedResult
        self.viewModel = viewModel
    }
    
    /// To check if spoken result contains decimal number words (like "one") and convert those words to digit number.
    /// This process is necessary since the first (few) speaking digit will be recognised as words instead of a digit number.
    internal func getFilteredResult() -> String {
        var filteredResult: String = spokenResult
        let appLanguage = AppLanguage.shared.getCurrentLanguage()
        
        switch appLanguage {
        case "en":
            let decimalNumberDictionary: [String: String] = [
                "zero": "0", "one": "1", "two": "2", "three": "3", "four": "4",
                "five": "5", "six": "6", "seven": "7", "eight": "8", "nine": "9"
            ]
            
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
            
        case "zh-Hans":
            let decimalNumberDictionary: [String: String] = [
                "零": "0", "一": "1", "二": "2", "三": "3", "四": "4",
                "五": "5", "六": "6", "七": "7", "八": "8", "九": "9",
                "零零": "00", "零一": "01", "零二": "02", "零三": "03", "零四": "04",
                "零五": "05", "零六": "06", "零七": "07", "零八": "08", "零九": "09",
                "一零": "10", "一一": "11", "一二": "12", "一三": "13", "一四": "14",
                "一五": "15", "一六": "16", "一七": "17", "一八": "18", "一九": "19",
                "二零": "20", "二一": "21", "二二": "22", "二三": "23", "二四": "24",
                "二五": "25", "二六": "26", "二七": "27", "二八": "28", "二九": "29",
                "三零": "30", "三一": "31", "三二": "32", "三三": "33", "三四": "34",
                "三五": "35", "三六": "36", "三七": "37", "三八": "38", "三九": "39",
                "四零": "40", "四一": "41", "四二": "42", "四三": "43", "四四": "44",
                "四五": "45", "四六": "46", "四七": "47", "四八": "48", "四九": "49",
                "五零": "50", "五一": "51", "五二": "52", "五三": "53", "五四": "54",
                "五五": "55", "五六": "56", "五七": "57", "五八": "58", "五九": "59",
                "六零": "60", "六一": "61", "六二": "62", "六三": "63", "六四": "64",
                "六五": "65", "六六": "66", "六七": "67", "六八": "68", "六九": "69",
                "七零": "70", "七一": "71", "七二": "72", "七三": "73", "七四": "74",
                "七五": "75", "七六": "76", "七七": "77", "七八": "78", "七九": "79",
                "八零": "80", "八一": "81", "八二": "82", "八三": "83", "八四": "84",
                "八五": "85", "八六": "86", "八七": "87", "八八": "88", "八九": "89",
                "九零": "90", "九一": "91", "九二": "92", "九三": "93", "九四": "94",
                "九五": "95", "九六": "96", "九七": "97", "九八": "98", "九九": "99"
            ]
            
            if decimalNumberDictionary.keys.contains(where: spokenResult.contains) {
                for key in decimalNumberDictionary.keys {
                    if spokenResult.lowercased() == key {
                        if let value = decimalNumberDictionary[key] {
                            filteredResult = value
                            break
                        }
                    }
                }
            }
            
        default:
            break
        }
        
        // Checking whether filteredResult only has decimal digits used to be here.
        
        return filteredResult
    }
    
    internal func getOptimizedResult() -> String {
        var filteredResult: String = getFilteredResult()
        if filteredResult.contains(expectedResult) {
            notificationBroadcast.post("Legal Spoken Result \(viewModel)", object: nil)
            
            print("Optimized for expectedResult: \(filteredResult)")
            return expectedResult
        } else {
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: filteredResult)) {
                notificationBroadcast.post("Legal Spoken Result \(viewModel)", object: nil)
            } else {
                filteredResult = "   " // Empty string will result in "Out of bounds" for extension UILabel func setCharacterSpacing().
                notificationBroadcast.post("Illegal Spoken Result \(viewModel)", object: nil)
            }
            
            print("Unable to optimize result: \(filteredResult)")
            return filteredResult
        }
    }
}
