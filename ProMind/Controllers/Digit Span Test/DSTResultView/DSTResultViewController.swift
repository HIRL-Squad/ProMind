//
//  DSTResultViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 9/8/21.
//

import UIKit
import Speech

class DSTResultViewController: UIViewController {
    @IBOutlet weak var forwardResultLabel: UILabel!
    @IBOutlet weak var backwardResultLabel: UILabel!
    @IBOutlet weak var sequencingResultLabel: UILabel!
    
    private let appLanguage = AppLanguage.shared
    private var synthesizer: AVSpeechSynthesizer?
    var gameResultStatistics: [DSTGameStatistics]?
    
    private let dstRecordCoreDataModel = DSTRecordCoreDataModel.shared
    
    private let testStatistics = DSTTestStatistics()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Experiment.shared.experimentType = .Test
//        Experiment.shared.age = 99
//        Experiment.shared.gender = .Male
//        Experiment.shared.remarks = "Test with Data Init in DST"
//        gameResultStatistics = [
//            DSTGameStatistics(totalTime: 72, numCorrectTrials: 5, currentSequence: 7, longestSequence: 5, maxDigits: 6),
//            DSTGameStatistics(totalTime: 123, numCorrectTrials: 4, currentSequence: 5, longestSequence: 2, maxDigits: 5),
//            DSTGameStatistics(totalTime: 157, numCorrectTrials: 3, currentSequence: 3, longestSequence: 1, maxDigits: 4)
//        ]
        Task {
            congratulate()
            await showResults()
            await saveResults()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        synthesizer?.stopSpeaking(at: .immediate)
        synthesizer = nil
    }
    
    private func congratulate() {
        synthesizer = AVSpeechSynthesizer()
        let currentLanguage = appLanguage.getCurrentLanguage()
        let localizedFinishMessage = K.DST.finishMessage.localized
        let utterance = AVSpeechUtterance(string: localizedFinishMessage)
        
        utterance.voice = AVSpeechSynthesisVoice(language: currentLanguage)
        utterance.rate = 0.4
        utterance.preUtteranceDelay = 0.5
        synthesizer?.speak(utterance)
    }
    
    private func showResults() async {
        
        guard let (forwardSpanTestData, backwardsSpanTestData) = try? await testStatistics.loadSavedData() else {
            print("Nil for test data!\n")
            forwardResultLabel.attributedText = testStatistics.getFormattedGameStats(testData: [:])
            backwardResultLabel.attributedText = testStatistics.getFormattedGameStats(testData: [:])
            return
        }
        
        forwardResultLabel.attributedText = testStatistics.getFormattedGameStats(testData: forwardSpanTestData)
        backwardResultLabel.attributedText = testStatistics.getFormattedGameStats(testData: backwardsSpanTestData)
        
        if let resultStats = gameResultStatistics {
            forwardResultLabel.attributedText = resultStats[0].getFormattedGameStats(fontSize: 28)
            backwardResultLabel.attributedText = resultStats[1].getFormattedGameStats(fontSize: 28)
            sequencingResultLabel.attributedText = resultStats[2].getFormattedGameStats(fontSize: 28)
        }
    }
    
    private func saveResults() async {
        print("Saving DST Results")
        
        let httpBody = await getDSTResultsJson()
        let url = URL(string: K.URL.saveDSTResult)
        
        print("HttpBody: \(String(describing: httpBody))")
        print("URL: \(String(describing: url))")
        
        Utils.postRequest(url: url, httpBody: httpBody)
    }
    
    private func getDSTResultsJson() async -> Data? {
        /*
        guard let resultStats = gameResultStatistics else {
            print("DST Result not available!")
            return nil
        }
         
        var body: [String: Any] = Experiment.shared.getExperimentBody()
        
        body["longestSequence"] = [resultStats[0].longestSequence, resultStats[1].longestSequence, resultStats[2].longestSequence]
        body["numCorrectTrials"] = [resultStats[0].numCorrectTrials, resultStats[1].numCorrectTrials, resultStats[2].numCorrectTrials]
        body["maxDigits"] = [resultStats[0].maxDigits, resultStats[1].maxDigits, resultStats[2].maxDigits]
        body["totalTimeTaken"] = [resultStats[0].totalTime, resultStats[1].totalTime, resultStats[2].totalTime]
        */
        
        guard let (forwardSpanTestData, backwardsSpanTestData) = try? await testStatistics.loadSavedData() else {
            print("Nil for test data!\n")
            return nil
        }
        
        var body: [String: Any] = Experiment.shared.getExperimentBody()
        
        body["longestSequence"] = [forwardSpanTestData["longestSequence"], backwardsSpanTestData["longestSequence"], nil] // check later!
        body["numCorrectTrials"] = [forwardSpanTestData["numCorrectTrials"], backwardsSpanTestData["numCorrectTrials"], nil]
        body["maxDigits"] = [forwardSpanTestData["maxDigits"], backwardsSpanTestData["maxDigits"], nil]
        body["totalTimeTaken"] = [forwardSpanTestData["totalTime"], backwardsSpanTestData["totalTime"], nil]
        
        print("body: \(body)")
        
        // Save data locally.
        let experimentDate: Int = body["experimentDate"] as? Int ?? 0
        let experimentType: String = body["experimentType"] as? String ?? "No Data"
        let age: Int = body["subjectAge"] as? Int ?? -1
        let gender: String = body["subjectGender"] as? String ?? "No Data"
        let annualIncome: String = body["subjectAnnualIncome"] as? String ?? "No Data"
        let educationLevel: String = body["subjectEducationLevel"] as? String ?? "No Data"
        let ethnicity: String = body["subjectEthnicity"] as? String ?? "No Data"
        let patientId: String = body["patientId"] as? String ?? "No Data"
        let remarks: String = body["remarks"] as? String ?? "No Data"
        
        let fstLongestSequence: Int = forwardSpanTestData["longestSequence"] as? Int ?? -1
        let fstMaxDigits: Int = forwardSpanTestData["maxDigits"] as? Int ?? -1
        let fstNumCorrectTrials: Int = forwardSpanTestData["numCorrectTrials"] as? Int ?? -1
        let fstTotalTimeTaken: Int = forwardSpanTestData["totalTime"] as? Int ?? -1
        let fstAudioPath: URL = getDocumentsDirectory()
        
        let bstLongestSequence: Int = backwardsSpanTestData["longestSequence"] as? Int ?? -1
        let bstMaxDigits: Int = backwardsSpanTestData["maxDigits"] as? Int ?? -1
        let bstNumCorrectTrials: Int = backwardsSpanTestData["numCorrectTrials"] as? Int ?? -1
        let bstTotalTimeTaken: Int = backwardsSpanTestData["totalTime"] as? Int ?? -1
        let bstAudioPath: URL = getDocumentsDirectory()
        
        dstRecordCoreDataModel.addTestRecord(experimentDate: experimentDate, experimentType: experimentType, age: age, gender: gender, annualIncome: annualIncome, educationLevel: educationLevel, ethnicity: ethnicity, patientId: patientId, remarks: remarks, fstLongestSequence: fstLongestSequence, fstMaxDigits: fstMaxDigits, fstNumCorrectTrials: fstNumCorrectTrials, fstTotalTimeTaken: fstTotalTimeTaken, fstAudioPath: fstAudioPath, bstLongestSequence: bstLongestSequence, bstMaxDigits: bstMaxDigits, bstNumCorrectTrials: bstNumCorrectTrials, bstTotalTimeTaken: bstTotalTimeTaken, bstAudioPath: bstAudioPath)
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
        
        Task {
            try await testStatistics.checkTestData()
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        splitViewController?.preferredDisplayMode = .oneBesideSecondary
        // navigationController?.popToRootViewController(animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        storyboard.instantiateInitialViewController()
        
        self.dismiss(animated: true)
    }
}
