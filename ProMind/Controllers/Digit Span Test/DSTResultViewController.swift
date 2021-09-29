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
    
    private var synthesizer: AVSpeechSynthesizer?
    var gameResultStatistics: [DSTGameStatistics]?
    
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
        
        congratulate()
        showResults()
        saveResults()
    }
    
    private func congratulate() {
        synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: K.DST.finishMessage)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")
        utterance.rate = K.UtteranceRate.instruction
        utterance.preUtteranceDelay = 0.5
        synthesizer?.speak(utterance)
    }
    
    private func showResults() {
        if let resultStats = gameResultStatistics {
            forwardResultLabel.attributedText = resultStats[0].getFormattedGameStats(fontSize: 28)
            backwardResultLabel.attributedText = resultStats[1].getFormattedGameStats(fontSize: 28)
            sequencingResultLabel.attributedText = resultStats[2].getFormattedGameStats(fontSize: 28)
        }
    }
    
    private func saveResults() {
        print("Saving DST Results")
        
        let httpBody = getDSTResultsJson()
        let url = URL(string: K.URL.saveDSTResult)
        
        Utils.postRequest(url: url, httpBody: httpBody)
    }
    
    private func getDSTResultsJson() -> Data? {
        guard let resultStats = gameResultStatistics else {
            print("DST Result not available!")
            return nil
        }
        
        var body: [String: Any] = Experiment.shared.getExperimentBody()
        body["longestSequence"] = [resultStats[0].longestSequence, resultStats[1].longestSequence, resultStats[2].longestSequence]
        body["numCorrectTrials"] = [resultStats[0].numCorrectTrials, resultStats[1].numCorrectTrials, resultStats[2].numCorrectTrials]
        body["maxDigits"] = [resultStats[0].maxDigits, resultStats[1].maxDigits, resultStats[2].maxDigits]
        body["totalTimeTaken"] = [resultStats[0].totalTime, resultStats[1].totalTime, resultStats[2].totalTime]
        
        print("body: \(body)")
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        splitViewController?.preferredDisplayMode = .oneBesideSecondary
        navigationController?.popToRootViewController(animated: true)
    }
}
