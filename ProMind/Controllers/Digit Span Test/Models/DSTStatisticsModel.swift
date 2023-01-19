//
//  DSTStatisticsModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 28/6/22.
//

import Foundation
import UIKit

enum DSTTestType {
    case unSet
    case forwardSpanTest
    case backwardsSpanTest
}

struct DSTTestResult: Identifiable {
    var id = UUID()
    let testType: DSTTestType
    
    var totalTime: UInt = 0
    var numCorrectTrials: Int = 0
    var currentSequence: Int = 0 /// Helper variable as a tracker
    var longestSequence: Int = 0
    var maxDigits: Int = 0
    
    init(testType: DSTTestType) {
        self.testType = testType
    }
}

class RoundInfo {
    var testType: DSTTestType
    var totalTrials: Int
    var currentDigits: Int
    var maxDigits: Int
    var currentSequence: Int
    
    var speechStatusIndex: Int
    var temporaryMaxDigits: Int
    var didMakeWrongAnswerInPreviousRound: Bool
    
    static let shared = RoundInfo(testType: .unSet) /// Singleton Pattern
    
    private init(testType: DSTTestType) {
        self.testType = testType
        self.totalTrials = 0
        self.currentDigits = 0
        self.maxDigits = 0
        self.currentSequence = 0
        
        self.speechStatusIndex = 0
        self.temporaryMaxDigits = 0
        self.didMakeWrongAnswerInPreviousRound = false
    }
    
    internal func reset() {
        /// We do not reset testType!
        totalTrials = 0
        currentDigits = 0
        maxDigits = 0
        currentSequence = 0
        
        /// We do not reset speechStatusIndex!
        temporaryMaxDigits = 0
        didMakeWrongAnswerInPreviousRound = false
    }
}

class DSTTestStatistics {
    
    @Published var forwardNumberTest = DSTTestResult(testType: .forwardSpanTest)
    @Published var backwardsNumberTest = DSTTestResult(testType: .backwardsSpanTest)
    
    internal var viewModel: DSTViewModels = .DSTTestViewModel
    private let notificationBroadcast = NotificationBroadcast()
    
    init() {
        notificationBroadcast.addObserver(self, #selector(updateTotalTime(notification:)), "Timer Increment \(viewModel)", object: nil)
    }
    
    deinit {
        notificationBroadcast.removeAllObserverFrom(self)
    }
    
    internal func saveData(testType: DSTTestType) async {
        let defaults = UserDefaults.standard
        
        switch testType {
        case .forwardSpanTest:
            let data = ["numCorrectTrials": forwardNumberTest.numCorrectTrials,
                        "maxDigits": forwardNumberTest.maxDigits,
                        "longestSequence": forwardNumberTest.longestSequence,
                        "totalTime": forwardNumberTest.totalTime,
                        "currentSequence": forwardNumberTest.currentSequence] as [String: Any]
            defaults.set(data, forKey: "Forward Span Test Data")
            
        case .backwardsSpanTest:
            let data = ["numCorrectTrials": backwardsNumberTest.numCorrectTrials,
                        "maxDigits": backwardsNumberTest.maxDigits,
                        "longestSequence": backwardsNumberTest.longestSequence,
                        "totalTime": backwardsNumberTest.totalTime,
                        "currentSequence": backwardsNumberTest.currentSequence] as [String: Any]
            defaults.set(data, forKey: "Backwards Span Test Data")
            
        default:
            break
        }
    }
    
    internal func loadSavedData() async throws -> ([String: Any], [String: Any])? {
        let defaults = UserDefaults.standard
        
        guard let forwardSpanTestData = defaults.object(forKey: "Forward Span Test Data") else {
            print("Nil Forwads Span Test Data!\n")
            throw DSTStatisticsError.nilForwardSpanTestData
        }
        
        guard let backwardsSpanTestData = defaults.object(forKey: "Backwards Span Test Data") else {
            print("Nil Backwards Span Test Data! \n")
            throw DSTStatisticsError.nilBackwardsSpanTestData
        }
        
        return (forwardSpanTestData, backwardsSpanTestData) as? ([String: Any], [String: Any])
    }
    
    internal func checkTestData() async throws {
        guard let (forwardSpanTestData, backwardsSpanTestData) = try? await loadSavedData() else {
            print("Unable to load and check test data!\n")
            throw DSTStatisticsError.unableToLoadTestData
        }
        
        print(forwardSpanTestData)
        print("\n")
        print(backwardsSpanTestData)
    }
    
    internal func correctAnswer(testType: DSTTestType) {
        let roundInfo = RoundInfo.shared
        
        switch testType {
        case .forwardSpanTest:
            forwardNumberTest.maxDigits = roundInfo.maxDigits
            forwardNumberTest.numCorrectTrials += 1
            forwardNumberTest.longestSequence = max(roundInfo.currentSequence, forwardNumberTest.longestSequence)
            
            print("Correct Answer!")
            printTestStatistics(.forwardSpanTest)
            
        case .backwardsSpanTest:
            backwardsNumberTest.maxDigits = roundInfo.maxDigits
            backwardsNumberTest.numCorrectTrials += 1
            backwardsNumberTest.longestSequence = max(roundInfo.currentSequence, backwardsNumberTest.longestSequence)
            
            print("Correct Answer!")
            printTestStatistics(.backwardsSpanTest)
            
        default:
            break
        }
    }
    
    internal func wrongAnswer(testType: DSTTestType) {
        switch testType {
        case .forwardSpanTest:
            print("Wrong Answer!")
            printTestStatistics(.forwardSpanTest)
            
        case .backwardsSpanTest:
            print("Wrong Answer!")
            printTestStatistics(.backwardsSpanTest)
            
        default:
            break
        }
    }
    
    @objc private func updateTotalTime(notification: Notification) throws {
        guard let (testType, counter) = notification.object as? (DSTTestType, UInt) else {
            print("Illegal Timer Counter!\n")
            throw TimerError.illegalTimerCounter
        }
        
        switch testType {
        case .forwardSpanTest:
            forwardNumberTest.totalTime = counter
            
        case.backwardsSpanTest:
            backwardsNumberTest.totalTime = counter
            
        default:
            break
        }
    }
    
    internal func reset() {
        forwardNumberTest.numCorrectTrials = 0
        forwardNumberTest.maxDigits = 0
        forwardNumberTest.longestSequence = 0
        forwardNumberTest.totalTime = 0
        forwardNumberTest.currentSequence = 0
        
        backwardsNumberTest.numCorrectTrials = 0
        backwardsNumberTest.maxDigits = 0
        backwardsNumberTest.longestSequence = 0
        backwardsNumberTest.totalTime = 0
        backwardsNumberTest.currentSequence = 0
    }
    
    private func printTestStatistics(_ testType: DSTTestType) {
        switch testType {
        case .forwardSpanTest:
            print("Max Digits: \(forwardNumberTest.maxDigits)")
            print("Number of Correct Trials: \(forwardNumberTest.numCorrectTrials)")
            print("Longest Sequences: \(forwardNumberTest.longestSequence)")
            print("Total Time: \(forwardNumberTest.totalTime)")
            print("\n")
            
        case .backwardsSpanTest:
            print("Max Digits: \(backwardsNumberTest.maxDigits)")
            print("Number of Correct Trials: \(backwardsNumberTest.numCorrectTrials)")
            print("Longest Sequences: \(backwardsNumberTest.longestSequence)")
            print("Total Time: \(backwardsNumberTest.totalTime)")
            print("\n")
            
        default:
            break
        }
    }
    
    internal func getFormattedGameStats(fontSize: CGFloat = 28, testData: Dictionary<String, Any>) -> NSMutableAttributedString {
        let statsText = NSMutableAttributedString.init()
        let attributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize)]
        let failureText = NSMutableAttributedString(string: "Failed to load test result!", attributes: attributes)
        
        guard let totalTime = testData["totalTime"],
              let maxDigits = testData["maxDigits"],
              let numCorrectTrials = testData["numCorrectTrials"],
              let longestSequence = testData["longestSequence"] else {
            print("Failed to load test result!\n")
            statsText.append(failureText)
            return statsText
        }

        let timeTakenText = NSMutableAttributedString(string: "Time Taken: ", attributes: attributes)
        timeTakenText.append(NSMutableAttributedString(string: "\(totalTime) s\n"))
        
        let maxDigitsText = NSMutableAttributedString(string: "Max Digits: ", attributes: attributes)
        maxDigitsText.append(NSMutableAttributedString(string: "\(maxDigits)\n"))
        
        let numCorrectTrialsText = NSMutableAttributedString(string: "Correct Trials: ", attributes: attributes)
        numCorrectTrialsText.append(NSMutableAttributedString(string: "\(numCorrectTrials)\n"))
        
        let longestSequenceText = NSMutableAttributedString(string: "Longest Seq: ", attributes: attributes)
        longestSequenceText.append(NSMutableAttributedString(string: "\(longestSequence)"))
    
        statsText.append(timeTakenText)
        statsText.append(maxDigitsText)
        statsText.append(numCorrectTrialsText)
        statsText.append(longestSequenceText)
        
        return statsText
    }
}
