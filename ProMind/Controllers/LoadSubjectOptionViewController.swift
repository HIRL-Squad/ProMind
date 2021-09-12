//
//  SubjectOptionViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/8/21.
//

import UIKit

class LoadSubjectOptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func createNewSubjectButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.goToSubjectProfileSegue, sender: self)
        
    }
    
    @IBAction func loadSubjectFromCloudButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.goToSubjectProfileSegue, sender: self)
        
    }
}
