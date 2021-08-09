//
//  DSTResultViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 9/8/21.
//

import UIKit

class DSTResultViewController: UIViewController {

    @IBOutlet weak var forwardResultLabel: UILabel!
    @IBOutlet weak var backwardResultLabel: UILabel!
    @IBOutlet weak var sequencingResultLabel: UILabel!
    
    var gameResultStatistics: [DSTGameStatistics]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let resultStats = gameResultStatistics {
            forwardResultLabel.attributedText = resultStats[0].getFormattedGameStats(fontSize: 28)
            backwardResultLabel.attributedText = resultStats[1].getFormattedGameStats(fontSize: 28)
            sequencingResultLabel.attributedText = resultStats[2].getFormattedGameStats(fontSize: 28)
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
