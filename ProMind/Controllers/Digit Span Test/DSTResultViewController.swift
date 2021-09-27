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
        
//        Subject.shared.subjectId = "1234@946684800"
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
        let utterance = AVSpeechUtterance(string: K.TMT.finishMessage)
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
    
    private func getTMTResultsJson() -> Data? {
        guard let resultStats = gameResultStatistics else {
            print("DST Result not available!")
            return nil
        }
        
        let body: [String: Any] = [
            "experimentType": "baseline",
            "date": Int64(Date.init().timeIntervalSince1970),
            "longestSequence": [
                resultStats[0].longestSequence,
                resultStats[1].longestSequence,
                resultStats[2].longestSequence,
            ],
            "numCorrectTrials": [
                resultStats[0].numCorrectTrials,
                resultStats[1].numCorrectTrials,
                resultStats[2].numCorrectTrials,
            ],
            "totalTimeTaken": [
                resultStats[0].totalTime,
                resultStats[1].totalTime,
                resultStats[2].totalTime
            ],
            "maxDigits": [
                resultStats[0].maxDigits,
                resultStats[1].maxDigits,
                resultStats[2].maxDigits,
            ]
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    private func saveResults() {
        print("Saving DST Results")
        
        guard let jsonBody = getTMTResultsJson() else {
            print("Failed to get DST results in JSON")
            return
        }

        let url = URL(string: K.URL.saveDSTResult)
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                
                print("Error occurred when sending a POST request: \(error?.localizedDescription ?? "Unknown Error")")
                
                // Possible connection error
                // Save to cache for persistent later
                
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("Status Code should be 2xx, but is \(response.statusCode)")
                print("Response = \(response)")
                return
            }

            print("Response Code: \(response.statusCode)")
            
            let responseString = String(data: data, encoding: .utf8)
            print("Response String = \(responseString ?? "Unable to decode response")")
        }
            
        task.resume()
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
