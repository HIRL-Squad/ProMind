//
//  TMTResultViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 11/7/21.
//

import UIKit
import Speech

class TMTResultViewController: UIViewController {
    static var numCircles = 25 // Default is 25
    
    @IBOutlet weak var numCirclesLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var resultLabelA: UILabel!
    @IBOutlet weak var resultLabelB: UILabel!
    
    private var synthesizer: AVSpeechSynthesizer?
    var gameResultStatistics: [TMTGameStatistics]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Experiment.shared.experimentType = .Test
//        Experiment.shared.age = 99
//        Experiment.shared.gender = .Male
//        Experiment.shared.remarks = "Test with Data Init in TMT"
//        gameResultStatistics = [
//            TMTGameStatistics(numCirclesLeft: 0, numErrors: 2, numLifts: 3, totalTimeTaken: 124),
//            TMTGameStatistics(numCirclesLeft: 0, numErrors: 5, numLifts: 8, totalTimeTaken: 179)
//        ]
        
        congratulate()
        showSettings()
        showResults()
        saveResults()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        synthesizer?.stopSpeaking(at: .immediate)
        synthesizer = nil
    }
    
    private func congratulate() {
        synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: K.TMT.finishMessage)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")
        utterance.rate = K.UtteranceRate.instruction
        utterance.preUtteranceDelay = 0.5
        synthesizer?.speak(utterance)
    }
    
    private func showSettings() {
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 36)]
        let numCirclesText = NSMutableAttributedString(string: "Number of Circles: ", attributes: attrs)
        numCirclesText.append(NSMutableAttributedString(string: "\(TMTResultViewController.numCircles)"))
        numCirclesLabel.attributedText = numCirclesText
        
        let totalTimeText = NSMutableAttributedString(string: "Total Time Given: ", attributes: attrs)
        totalTimeText.append(NSMutableAttributedString(string: "\(K.TMT.numCirclesTimeMapping[TMTResultViewController.numCircles] ?? 301) s"))
        totalTimeLabel.attributedText = totalTimeText
    }
    
    private func showResults() {
        if let resultStats = gameResultStatistics {
            resultLabelA.attributedText = resultStats[0].getFormattedGameResults()
            resultLabelB.attributedText = resultStats[1].getFormattedGameResults()
        }
    }
    
    private func saveResults() {
        print("Saving TMT Results")
        
        let httpBody = getTMTResultsJson()
        let url = URL(string: K.URL.saveTMTResult)
        
        Utils.postRequest(url: url, httpBody: httpBody)
    }
    
    private func getTMTResultsJson() -> Data? {
        guard let resultStats = gameResultStatistics else {
            print("TMT Result not available!")
            return nil
        }
        
        var body: [String: Any] = Experiment.shared.getExperimentBody()
        body["numStartingCircles"] = TMTResultViewController.numCircles
        body["totalTimeTaken"] = [resultStats[0].totalTimeTaken, resultStats[1].totalTimeTaken]
        body["numCirclesLeft"] = [resultStats[0].numCirclesLeft, resultStats[1].numCirclesLeft]
        body["numErrors"] = [resultStats[0].numErrors, resultStats[1].numErrors]
        body["numLifts"] = [resultStats[0].numLifts, resultStats[1].numLifts]
        
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
