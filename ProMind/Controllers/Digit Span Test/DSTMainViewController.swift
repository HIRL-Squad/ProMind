//
//  DSTMainViewController.swift
//  ProMind
//
//  Created by Tan Wee Keat on 26/6/21.
//

import UIKit

class DSTMainViewController: UIViewController {

    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DSTMainViewController.viewDidLoad() loaded successfully:", text ?? "Failed to pass data")

        // Do any additional setup after loading the view.
    }

}
