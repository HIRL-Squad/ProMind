//
//  SubjectOptionViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/8/21.
//

import UIKit

class InitialViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegue(withIdentifier: K.goToExperimentProfileSegue, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let splitViewController = segue.destination as? UISplitViewController,
              let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
              let _ = leftNavController.viewControllers.first as? ExperimentProfileMasterViewController else {
            fatalError("InitialScreenViewController: Errors occurred while downcasting to SubjectProfileMasterViewController.")
        }
    }
}
