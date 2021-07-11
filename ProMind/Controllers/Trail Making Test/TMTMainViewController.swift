//
//  TMTMainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/6/21.
//

import UIKit

class TMTMainViewController: UIViewController {

    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TMTMainViewController.viewDidLoad() loaded successfully:", text ?? "Failed to pass data")
    }
    
//    @IBAction func backButtonPressed(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
}
