//
//  MainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 6/6/21.
//

import UIKit
import CLTypingLabel

class TestSelectionViewController: UIViewController {
    @IBOutlet weak var titleLabel: CLTypingLabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        titleLabel.text = K.appName
        titleLabel.charInterval = K.charIntervalRate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        splitViewController?.preferredDisplayMode = .secondaryOnly // Only show the Detail view (To prevent showing subject profile).
    }
    
    @IBAction func backBarButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        self.splitViewController?.preferredDisplayMode = .oneBesideSecondary // Show both Master and Detail views.
    }
    
    // To prepare for new view controller before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case K.goToTMTSegue,
             K.goToDSTSegue:
            print("MainViewController.prepare(): Going to \(segue.identifier!)")
            break
        default:
            print("MainViewController.prepare(): No segue identifier is matched")
        }
        
    }
}

