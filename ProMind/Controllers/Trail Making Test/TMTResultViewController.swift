//
//  TMTResultViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 11/7/21.
//

import UIKit
import Speech

// TODO:
// 1. Congrats on completion.
// 2. Show results.
// 3. Send HTTP POST to save results.

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
        
//        Subject.shared.subjectId = "4567@948153600"
//        gameResultStatistics = [
//            TMTGameStatistics(numCirclesLeft: 0, numErrors: 2, numLifts: 3, totalTimeTaken: 124),
//            TMTGameStatistics(numCirclesLeft: 0, numErrors: 5, numLifts: 8, totalTimeTaken: 179)
//        ]
        
        congratulate()
        showSettings()
        showResults()
        saveResults()
    }
    
    private func congratulate() {
        synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "Congratulations. You have completed the Trail Making Test. Please refer to your results on the screen.")
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")
        utterance.rate = K.UtteranceRate.instruction
        utterance.preUtteranceDelay = 1.0
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
    
    private func getTMTResultsJson() -> Data? {
        guard let subjectId = Subject.shared.subjectId else {
            print("Subject ID not available!")
            return nil
        }
        
        guard let resultStats = gameResultStatistics else {
            print("TMT Result not available!")
            return nil
        }
        
        let body: [String: Any] = [
            "experimentType": "baseline",
            "numErrors": [
                resultStats[0].numErrors,
                resultStats[1].numErrors
            ],
            "totalTimeTaken": [
                resultStats[0].totalTimeTaken,
                resultStats[1].totalTimeTaken
            ],
            "date": Int64(Date.init().timeIntervalSince1970),
            "subjectId": subjectId,
            "numStartingCircles": TMTResultViewController.numCircles,
            "numCirclesLeft": [
                resultStats[0].numCirclesLeft,
                resultStats[1].numCirclesLeft
            ],
            "numLifts": [
                resultStats[0].numLifts,
                resultStats[1].numLifts
            ]
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    private func saveResults() {
        print("Saving TMT Results")
        
        guard let jsonBody = getTMTResultsJson() else {
            print("Failed to get TMT results in JSON")
            return
        }

        let url = URL(string: K.URL.saveTMTResult)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        // RESET EVERYTHING!!
        splitViewController?.preferredDisplayMode = .oneBesideSecondary
        navigationController?.popToRootViewController(animated: true)
    }

}
