//
//  TMTResultViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 11/7/21.
//

import UIKit
import Speech

class TMTResultViewController: UIViewController {
    static var numCircles = 15 // Default is 25
    
    @IBOutlet weak var numCirclesLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var resultLabelA: UILabel!
    @IBOutlet weak var resultLabelB: UILabel!
    
    private var synthesizer: AVSpeechSynthesizer?
    var gameResultStatistics: [TMTGameStatistics]?
    
    let tmtRecordCoreDataModel = TMTRecordCoreDataModel.shared
    
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
        synthesizer = AVSpeechSynthesizer()
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
        let utterance = AVSpeechUtterance(string: K.TMT.finishMessage.localized)
        let appLanguage = AppLanguage.shared.getCurrentLanguage()
        
        utterance.voice = AVSpeechSynthesisVoice(language: appLanguage)
        utterance.rate = 0.4
        utterance.preUtteranceDelay = 0.5
        
        synthesizer?.speak(utterance)
    }
    
    private func showSettings() {
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 36)]
        let numCirclesText = NSMutableAttributedString(string: "Number of Circles: ", attributes: attrs)
        numCirclesText.append(NSMutableAttributedString(string: "\(15)"))
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
        
        // ExperimentBody() already has the patient information.
        var body: [String: Any] = Experiment.shared.getExperimentBody()
        
        body["numStartingCircles"] = 15
        body["totalTimeTaken"] = [resultStats[0].totalTimeTaken, resultStats[1].totalTimeTaken]
        body["numCirclesLeft"] = [resultStats[0].numCirclesLeft, resultStats[1].numCirclesLeft]
        body["numErrors"] = [resultStats[0].numErrors, resultStats[1].numErrors]
        body["numLifts"] = [resultStats[0].numLifts, resultStats[1].numLifts]
        
        print("body: \(body)")
        
        saveTestRecordLocally(body)
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    private func saveTestRecordLocally(_ body: [String: Any]) {
        let experimentDate: Int64 = body["experimentDate"] as? Int64 ?? 0
        let experimentType: String = body["experimentType"] as? String ?? "No Data"
        let age: Int = body["subjectAge"] as? Int ?? -1
        let gender: String = body["subjectGender"] as? String ?? "No Data"
        let annualIncome: String = body["subjectAnnualIncome"] as? String ?? "No Data"
        let educationLevel: String = body["subjectEducationLevel"] as? String ?? "No Data"
        let ethnicity: String = body["subjectEthnicity"] as? String ?? "No Data"
        let patientId: String = body["patientId"] as? String ?? "No Data"
        let remarks: String = body["remarks"] as? String ?? "No Data"
        let tmtNumStartingCircles: Int = 15
        
        if let resultStats = gameResultStatistics {
            let tmtNumCirclesLeftTestA: Int = resultStats[0].numCirclesLeft
            let tmtNumErrorsTestA: Int = resultStats[0].numErrors
            let tmtNumLiftsTestA: Int = resultStats[0].numLifts
            let tmtTotalTimeTakenTestA: Int = resultStats[0].totalTimeTaken
            let tmtImagePathTestA: URL = resultStats[0].screenshotPath
            
            let tmtNumCirclesLeftTestB: Int = resultStats[1].numCirclesLeft
            let tmtNumErrorsTestB: Int = resultStats[1].numErrors
            let tmtNumLiftsTestB: Int = resultStats[1].numLifts
            let tmtTotalTimeTakenTestB: Int = resultStats[1].totalTimeTaken
            let tmtImagePathTestB: URL = resultStats[1].screenshotPath
            
            tmtRecordCoreDataModel.addTestRecord(experimentDate: experimentDate, experimentType: experimentType, age: age, gender: gender, annualIncome: annualIncome, educationLevel: educationLevel, ethnicity: ethnicity, patientId: patientId, remarks: remarks, tmtNumStartingCircles: tmtNumStartingCircles, tmtNumCirclesLeftTestA: tmtNumCirclesLeftTestA, tmtNumErrorsTestA: tmtNumErrorsTestA, tmtNumLiftsTestA: tmtNumLiftsTestA, tmtTotalTimeTakenTestA: tmtTotalTimeTakenTestA, tmtImagePathTestA: tmtImagePathTestA, tmtNumCirclesLeftTestB: tmtNumCirclesLeftTestB, tmtNumErrorsTestB: tmtNumErrorsTestB, tmtNumLiftsTestB: tmtNumLiftsTestB, tmtTotalTimeTakenTestB: tmtTotalTimeTakenTestB, tmtImagePathTestB: tmtImagePathTestB)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
