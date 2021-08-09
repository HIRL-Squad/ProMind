//
//  TMTResultViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 11/7/21.
//

import UIKit

class TMTResultViewController: UIViewController {

    @IBOutlet weak var resultLabelA: UILabel!
    @IBOutlet weak var resultLabelB: UILabel!
    
    var gameResultStatistics: [TMTGameStatistics]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let resultStats = gameResultStatistics {
            resultLabelA.attributedText = resultStats[0].getFormattedGameResults()
            resultLabelB.attributedText = resultStats[1].getFormattedGameResults()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

}
