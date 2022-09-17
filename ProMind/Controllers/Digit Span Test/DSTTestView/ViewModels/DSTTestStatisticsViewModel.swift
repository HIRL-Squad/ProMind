//
//  DSTTestStatisticsViewModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 28/6/22.
//

import Foundation
import SwiftUI


class DSTTestStatisticsViewModel: NSObject, ObservableObject {
    @Published var forwardNumberTest = DSTTestResult(testType: .forwardSpanTest)
    @Published var backwardsNumberTest = DSTTestResult(testType: .backwardsSpanTest)
    
    private let notificationBroadcast = NotificationBroadcast()
    internal var viewModel: DSTViewModels
    
    override init() {
        self.viewModel = .DSTTestViewModel
        super.init()
        
        notificationBroadcast.removeAllObserverFrom(self)
        notificationBroadcast.addObserver(self, selector: #selector(correctAnswer), name: "Correct Answer \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(wrongAnswer), name: "Wrong Answer \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(updateTotalTime(notification:)), name: "Timer Increment \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(saveData(notification:)), name: "Save Test Data \(viewModel)", object: nil)
        notificationBroadcast.addObserver(self, selector: #selector(getTestData), name: "Get Test Data \(viewModel)", object: nil)
    }
    
    deinit {
        notificationBroadcast.removeAllObserverFrom(self)
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
    
    @objc private func getTestData() async throws {
        guard let (forwardSpanTestData, backwardsSpanTestData) = try? await loadSavedData() else {
            print("Nil for test data!\n")
            return
        }
        
        print(forwardSpanTestData)
        print("\n")
        print(backwardsSpanTestData)
    }
    
    @objc private func correctAnswer(notification: Notification) throws {
        guard let testType = notification.object as? DSTTestType else {
            print("Illegal Test Type for correctAnswer!\n")
            throw DSTStatisticsError.illegalTestType
        }
        
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
            throw DSTStatisticsError.illegalTestType
        }
    }
    
    @objc private func wrongAnswer(notification: Notification) throws {
        guard let testType = notification.object as? DSTTestType else {
            print("Illegal Test Type for wrongAnswer!\n")
            throw DSTStatisticsError.illegalTestType
        }
        
        switch testType {
        case .forwardSpanTest:
            print("Wrong Answer!")
            printTestStatistics(.forwardSpanTest)
            
        case .backwardsSpanTest:
            print("Wrong Answer!")
            printTestStatistics(.backwardsSpanTest)
            
        default:
            throw DSTStatisticsError.illegalTestType
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
            throw TimerError.illegalTimerCounter
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
    
    @objc internal func saveData(notification: Notification) throws {
        guard let testType = notification.object as? DSTTestType else {
            print("Illegal Test Type for saveData()!\n")
            throw DSTStatisticsError.illegalTestType
        }
        
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
            throw DSTStatisticsError.illegalTestType
        }
    }
    
    internal func loadSavedData() async throws -> (Dictionary<String, Any>, Dictionary<String, Any>)? {
        let defaults = UserDefaults.standard
        
        guard let forwardSpanTestData = defaults.object(forKey: "Forward Span Test Data") else {
            print("Nil Forwads Span Test Data!\n")
            throw DSTStatisticsError.nilForwardSpanTestData
        }
        
        guard let backwardsSpanTestData = defaults.object(forKey: "Backwards Span Test Data") else {
            print("Nil Backwards Span Test Data!\n")
            throw DSTStatisticsError.nilBackwardsSpanTestData
        }
        
        return (forwardSpanTestData, backwardsSpanTestData) as? (Dictionary<String, Any>, Dictionary<String, Any>)
    }
    
    internal func getFormattedGameStats(fontSize: CGFloat = 16, testData: Dictionary<String, Any>) -> NSMutableAttributedString {
        let statsText = NSMutableAttributedString.init()
        let attributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize)]
        let failureText = NSMutableAttributedString(string: "Failed to load test result!", attributes: attributes)
        
        guard let totalTime = testData["totalTime"],
              let maxDigits = testData["maxDigits"],
              let numCorrectTrials = testData["numCorrectTrials"],
              let longestSequence = testData["longestSequence"] else {
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
