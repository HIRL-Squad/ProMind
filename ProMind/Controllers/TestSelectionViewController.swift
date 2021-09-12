//
//  MainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 6/6/21.
//

import UIKit

class TestSelectionViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animate Label, can consider using CLTypingLabel
        titleLabel.text = ""
        var charIdx: Double = 0
        let titleText = "ProMind"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIdx, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIdx += 1
        }
    }
    @IBAction func backBarButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        self.splitViewController?.preferredDisplayMode = .oneBesideSecondary
        
//        dismiss(animated: true) {
//            self.splitViewController?.preferredDisplayMode = .oneBesideSecondary
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // To prevent showing subject profile.
        splitViewController?.preferredDisplayMode = .secondaryOnly
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

