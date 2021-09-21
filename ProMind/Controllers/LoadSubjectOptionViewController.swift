//
//  SubjectOptionViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/8/21.
//

import UIKit

class LoadSubjectOptionViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Consider using CLTypingLabel
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let splitViewController = segue.destination as? UISplitViewController,
              let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
              let subjectProfileMasterViewController = leftNavController.viewControllers.first as? SubjectProfileMasterViewController else {
            fatalError("LoadSubjectOptionViewController: Errors occurred while downcasting to SubjectProfileMasterViewController.")
        }
        
        if segue.identifier == K.goToSubjectProfileToCreateNewSubjectSegue {
            subjectProfileMasterViewController.isLoadingSubject = false
            subjectProfileMasterViewController.enterFromLoadSubjectOption = true
        } else if segue.identifier == K.goToSubjectProfileToLoadSubjectSegue {
            subjectProfileMasterViewController.isLoadingSubject = true
            subjectProfileMasterViewController.enterFromLoadSubjectOption = true
        }
    }
}
